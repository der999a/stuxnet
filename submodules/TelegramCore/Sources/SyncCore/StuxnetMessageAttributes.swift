import Foundation
import Postbox

public struct StuxnetMessageRevision: Codable, Equatable {
    public let text: String
    public let timestamp: Int32

    public init(text: String, timestamp: Int32) {
        self.text = text
        self.timestamp = timestamp
    }
}

public final class StuxnetMessageHistoryAttribute: MessageAttribute {
    public let revisions: [StuxnetMessageRevision]

    public init(revisions: [StuxnetMessageRevision]) {
        self.revisions = revisions
    }

    public init(decoder: PostboxDecoder) {
        if let data = decoder.decodeDataForKey("d"), let revisions = try? JSONDecoder().decode([StuxnetMessageRevision].self, from: data) {
            self.revisions = revisions
        } else {
            self.revisions = []
        }
    }

    public func encode(_ encoder: PostboxEncoder) {
        if let data = try? JSONEncoder().encode(self.revisions) {
            encoder.encodeData(data, forKey: "d")
        }
    }
}

public final class StuxnetDeletedMessageAttribute: MessageAttribute {
    public let timestamp: Int32

    public init(timestamp: Int32) {
        self.timestamp = timestamp
    }

    public init(decoder: PostboxDecoder) {
        self.timestamp = decoder.decodeInt32ForKey("t", orElse: 0)
    }

    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.timestamp, forKey: "t")
    }
}

public extension Message {
    var stuxnetIsDeleted: Bool {
        return self.attributes.contains(where: { $0 is StuxnetDeletedMessageAttribute })
    }

    var stuxnetDeletedTimestamp: Int32? {
        return (self.attributes.first(where: { $0 is StuxnetDeletedMessageAttribute }) as? StuxnetDeletedMessageAttribute)?.timestamp
    }

    var stuxnetRevisions: [StuxnetMessageRevision] {
        return (self.attributes.first(where: { $0 is StuxnetMessageHistoryAttribute }) as? StuxnetMessageHistoryAttribute)?.revisions ?? []
    }
}

func stuxnetShouldPreserveDeletedMessages(transaction: Transaction, peerId: PeerId, settings: StuxnetSettings) -> Bool {
    guard settings.saveDeletedMessages else {
        return false
    }
    let isBotChat = (transaction.getPeer(peerId) as? TelegramUser)?.botInfo != nil
    return settings.saveForBots || !isBotChat
}

func stuxnetShouldPreserveDeletedMessage(transaction: Transaction, id: MessageId, settings: StuxnetSettings) -> Bool {
    return stuxnetShouldPreserveDeletedMessages(transaction: transaction, peerId: id.peerId, settings: settings)
}

func stuxnetAttributesPreservingLocalData(previousMessage: Message, updatedAttributes: [MessageAttribute]) -> [MessageAttribute] {
    let history = previousMessage.attributes.first(where: { $0 is StuxnetMessageHistoryAttribute })
    let deleted = previousMessage.attributes.first(where: { $0 is StuxnetDeletedMessageAttribute })
    guard history != nil || deleted != nil else {
        return updatedAttributes
    }
    var result = updatedAttributes.filter { attribute in
        return !(attribute is StuxnetMessageHistoryAttribute) && !(attribute is StuxnetDeletedMessageAttribute)
    }
    if let history {
        result.append(history)
    }
    if let deleted {
        result.append(deleted)
    }
    return result
}

func stuxnetMarkMessageDeleted(transaction: Transaction, id: MessageId, timestamp: Int32) {
    transaction.updateMessage(id, update: { message in
        let hadDeletedAttribute = message.attributes.contains(where: { $0 is StuxnetDeletedMessageAttribute })
        let hadAutoremoveAttribute = message.attributes.contains(where: { $0 is AutoremoveTimeoutMessageAttribute || $0 is AutoclearTimeoutMessageAttribute })
        var attributes = message.attributes.filter { attribute in
            return !(attribute is AutoremoveTimeoutMessageAttribute) && !(attribute is AutoclearTimeoutMessageAttribute)
        }
        if !hadDeletedAttribute {
            attributes.append(StuxnetDeletedMessageAttribute(timestamp: timestamp))
        }

        var tags = message.tags
        tags.remove(.unseenPersonalMessage)
        tags.remove(.unseenReaction)
        tags.remove(.unseenPollVote)

        var flags = StoreMessageFlags(message.flags)
        flags.remove(.CountedAsIncoming)

        if hadDeletedAttribute && !hadAutoremoveAttribute && tags == message.tags && flags == StoreMessageFlags(message.flags) {
            return .skip
        }
        var forwardInfo: StoreMessageForwardInfo?
        if let currentForwardInfo = message.forwardInfo {
            forwardInfo = StoreMessageForwardInfo(
                authorId: currentForwardInfo.author?.id,
                sourceId: currentForwardInfo.source?.id,
                sourceMessageId: currentForwardInfo.sourceMessageId,
                date: currentForwardInfo.date,
                authorSignature: currentForwardInfo.authorSignature,
                psaType: currentForwardInfo.psaType,
                flags: currentForwardInfo.flags
            )
        }
        return .update(StoreMessage(
            id: message.id,
            customStableId: nil,
            globallyUniqueId: message.globallyUniqueId,
            groupingKey: message.groupingKey,
            threadId: message.threadId,
            timestamp: message.timestamp,
            flags: flags,
            tags: tags,
            globalTags: message.globalTags,
            localTags: message.localTags,
            forwardInfo: forwardInfo,
            authorId: message.author?.id,
            text: message.text,
            attributes: attributes,
            media: message.media
        ))
    })
}

@discardableResult
func stuxnetMarkDeletedMessages(transaction: Transaction, ids: [MessageId], timestamp: Int32, settings: StuxnetSettings) -> [MessageId] {
    var idsToDelete: [MessageId] = []
    idsToDelete.reserveCapacity(ids.count)
    for id in ids {
        if stuxnetShouldPreserveDeletedMessage(transaction: transaction, id: id, settings: settings) {
            stuxnetMarkMessageDeleted(transaction: transaction, id: id, timestamp: timestamp)
        } else {
            idsToDelete.append(id)
        }
    }
    return idsToDelete
}

@discardableResult
func stuxnetMarkDeletedMessagesInIdRange(transaction: Transaction, peerId: PeerId, namespace: MessageId.Namespace, minId: MessageId.Id, maxId: MessageId.Id, timestamp: Int32, settings: StuxnetSettings) -> Bool {
    guard stuxnetShouldPreserveDeletedMessages(transaction: transaction, peerId: peerId, settings: settings) else {
        return false
    }
    var messageIds: [MessageId] = []
    transaction.withAllMessages(peerId: peerId, namespace: namespace, { message in
        if message.id.id >= minId && message.id.id <= maxId {
            messageIds.append(message.id)
        }
        return true
    })
    for messageId in messageIds {
        stuxnetMarkMessageDeleted(transaction: transaction, id: messageId, timestamp: timestamp)
    }
    return true
}

@discardableResult
func stuxnetMarkDeletedHistory(transaction: Transaction, peerId: PeerId, threadId: Int64?, namespaces: MessageIdNamespaces, minTimestamp: Int32? = nil, maxTimestamp: Int32? = nil, timestamp: Int32, settings: StuxnetSettings) -> Bool {
    guard stuxnetShouldPreserveDeletedMessages(transaction: transaction, peerId: peerId, settings: settings) else {
        return false
    }
    var messageIds: [MessageId] = []
    transaction.withAllMessages(peerId: peerId, { message in
        guard namespaces.contains(message.id.namespace) else {
            return true
        }
        if let threadId, message.threadId != threadId {
            return true
        }
        if let minTimestamp, message.timestamp < minTimestamp {
            return true
        }
        if let maxTimestamp, message.timestamp > maxTimestamp {
            return true
        }
        messageIds.append(message.id)
        return true
    })
    for messageId in messageIds {
        stuxnetMarkMessageDeleted(transaction: transaction, id: messageId, timestamp: timestamp)
    }
    return true
}

func stuxnetAttributesWithRevision(previousMessage: Message, updatedAttributes: [MessageAttribute], timestamp: Int32) -> [MessageAttribute] {
    var result = stuxnetAttributesPreservingLocalData(previousMessage: previousMessage, updatedAttributes: updatedAttributes)
    result.removeAll(where: { $0 is StuxnetMessageHistoryAttribute })
    var revisions = previousMessage.stuxnetRevisions
    if !previousMessage.text.isEmpty && revisions.last?.text != previousMessage.text {
        revisions.append(StuxnetMessageRevision(text: previousMessage.text, timestamp: timestamp))
    }
    if revisions.count > 100 {
        revisions.removeFirst(revisions.count - 100)
    }
    if !revisions.isEmpty {
        result.append(StuxnetMessageHistoryAttribute(revisions: revisions))
    }
    return result
}
