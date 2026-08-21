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

    var stuxnetRevisions: [StuxnetMessageRevision] {
        return (self.attributes.first(where: { $0 is StuxnetMessageHistoryAttribute }) as? StuxnetMessageHistoryAttribute)?.revisions ?? []
    }
}

func stuxnetMarkMessageDeleted(transaction: Transaction, id: MessageId, timestamp: Int32) {
    transaction.updateMessage(id, update: { message in
        if message.attributes.contains(where: { $0 is StuxnetDeletedMessageAttribute }) {
            return .skip
        }
        var attributes = message.attributes
        attributes.append(StuxnetDeletedMessageAttribute(timestamp: timestamp))
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
            flags: StoreMessageFlags(message.flags),
            tags: message.tags,
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

func stuxnetAttributesWithRevision(previousMessage: Message, updatedAttributes: [MessageAttribute], timestamp: Int32) -> [MessageAttribute] {
    var result = updatedAttributes.filter { !($0 is StuxnetMessageHistoryAttribute) }
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
