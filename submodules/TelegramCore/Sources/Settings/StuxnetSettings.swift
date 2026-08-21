import Foundation
import Postbox
import SwiftSignalKit

public struct StuxnetLocalGiftTransfer: Codable, Equatable {
    public var recipient: String
    public var recipientPeerId: Int64?
    public var timestamp: Int32

    public init(recipient: String, recipientPeerId: Int64? = nil, timestamp: Int32) {
        self.recipient = recipient
        self.recipientPeerId = recipientPeerId
        self.timestamp = timestamp
    }

    private enum CodingKeys: String, CodingKey {
        case recipient
        case recipientPeerId
        case timestamp
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recipient = try container.decode(String.self, forKey: .recipient)
        self.recipientPeerId = try container.decodeIfPresent(Int64.self, forKey: .recipientPeerId)
        self.timestamp = try container.decode(Int32.self, forKey: .timestamp)
    }
}

public struct StuxnetLocalGift: Codable, Equatable {
    public var id: String
    public var title: String
    public var model: String
    public var symbol: String
    public var color: UInt32
    public var number: Int32?
    public var background: String
    public var visible: Bool
    public var pinned: Bool
    public var equipped: Bool
    public var localOwner: String
    public var localOwnerPeerId: Int64?
    public var transfers: [StuxnetLocalGiftTransfer]
    public var sourceGift: StarGift?
    public var previewAttributes: [StarGift.UniqueGift.Attribute]
    public var createdAt: Int32

    public init(
        id: String,
        title: String,
        model: String,
        symbol: String,
        color: UInt32,
        number: Int32? = nil,
        background: String = "Default",
        visible: Bool,
        pinned: Bool,
        equipped: Bool = false,
        localOwner: String = "Me",
        localOwnerPeerId: Int64? = nil,
        transfers: [StuxnetLocalGiftTransfer] = [],
        sourceGift: StarGift? = nil,
        previewAttributes: [StarGift.UniqueGift.Attribute] = [],
        createdAt: Int32 = Int32(Date().timeIntervalSince1970)
    ) {
        self.id = id
        self.title = title
        self.model = model
        self.symbol = symbol
        self.color = color
        self.number = number
        self.background = background
        self.visible = visible
        self.pinned = pinned
        self.equipped = equipped
        self.localOwner = localOwner
        self.localOwnerPeerId = localOwnerPeerId
        self.transfers = transfers
        self.sourceGift = sourceGift
        self.previewAttributes = previewAttributes
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case model
        case symbol
        case color
        case number
        case background
        case visible
        case pinned
        case equipped
        case localOwner
        case localOwnerPeerId
        case transfers
        case sourceGift
        case previewAttributes
        case createdAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.model = try container.decode(String.self, forKey: .model)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.color = try container.decode(UInt32.self, forKey: .color)
        self.number = try container.decodeIfPresent(Int32.self, forKey: .number)
        self.background = try container.decodeIfPresent(String.self, forKey: .background) ?? "Default"
        self.visible = try container.decodeIfPresent(Bool.self, forKey: .visible) ?? true
        self.pinned = try container.decodeIfPresent(Bool.self, forKey: .pinned) ?? false
        self.equipped = try container.decodeIfPresent(Bool.self, forKey: .equipped) ?? false
        self.localOwner = try container.decodeIfPresent(String.self, forKey: .localOwner) ?? "Me"
        self.localOwnerPeerId = try container.decodeIfPresent(Int64.self, forKey: .localOwnerPeerId)
        self.transfers = try container.decodeIfPresent([StuxnetLocalGiftTransfer].self, forKey: .transfers) ?? []
        self.sourceGift = try container.decodeIfPresent(StarGift.self, forKey: .sourceGift)
        self.previewAttributes = try container.decodeIfPresent([StarGift.UniqueGift.Attribute].self, forKey: .previewAttributes) ?? []
        self.createdAt = try container.decodeIfPresent(Int32.self, forKey: .createdAt) ?? 0
    }

    public var catalogGiftId: Int64? {
        switch self.sourceGift {
        case let .generic(gift):
            return gift.id
        case let .unique(gift):
            return gift.giftId
        case nil:
            return nil
        }
    }

    public var uniqueSlug: String? {
        if case let .unique(gift) = self.sourceGift, !gift.slug.isEmpty {
            return gift.slug
        }
        return nil
    }

    public func isOwned(by peerId: PeerId, accountPeerId: PeerId) -> Bool {
        if let localOwnerPeerId = self.localOwnerPeerId {
            return localOwnerPeerId == peerId.toInt64()
        } else {
            return peerId == accountPeerId
        }
    }

    private static func normalizedPreviewAttributes(_ attributes: [StarGift.UniqueGift.Attribute]) -> [StarGift.UniqueGift.Attribute]? {
        var model: StarGift.UniqueGift.Attribute?
        var pattern: StarGift.UniqueGift.Attribute?
        var backdrop: StarGift.UniqueGift.Attribute?
        var originalInfo: [StarGift.UniqueGift.Attribute] = []
        for attribute in attributes {
            switch attribute {
            case .model:
                if model == nil {
                    model = attribute
                }
            case .pattern:
                if pattern == nil {
                    pattern = attribute
                }
            case .backdrop:
                if backdrop == nil {
                    backdrop = attribute
                }
            case .originalInfo:
                originalInfo.append(attribute)
            }
        }
        guard let model, let pattern, let backdrop else {
            return nil
        }
        return [model, pattern, backdrop] + originalInfo
    }

    public var effectivePreviewAttributes: [StarGift.UniqueGift.Attribute]? {
        guard case .unique = self.sourceGift else {
            return nil
        }
        return Self.normalizedPreviewAttributes(self.previewAttributes)
    }

    public var effectiveSourceGift: StarGift? {
        guard let sourceGift = self.sourceGift else {
            return nil
        }
        guard case let .unique(value) = sourceGift,
              let previewAttributes = self.effectivePreviewAttributes else {
            return sourceGift
        }
        return .unique(StarGift.UniqueGift(
            id: value.id,
            giftId: value.giftId,
            title: value.title,
            number: self.number ?? value.number,
            slug: value.slug,
            owner: value.owner,
            attributes: previewAttributes,
            availability: value.availability,
            giftAddress: value.giftAddress,
            resellAmounts: value.resellAmounts,
            resellForTonOnly: value.resellForTonOnly,
            releasedBy: value.releasedBy,
            valueAmount: value.valueAmount,
            valueCurrency: value.valueCurrency,
            valueUsdAmount: value.valueUsdAmount,
            flags: value.flags,
            themePeerId: value.themePeerId,
            peerColor: value.peerColor,
            hostPeerId: value.hostPeerId,
            minOfferStars: value.minOfferStars,
            craftChancePermille: value.craftChancePermille
        ))
    }

    public var profileGift: ProfileGiftsContext.State.StarGift? {
        guard let gift = self.effectiveSourceGift else {
            return nil
        }
        return ProfileGiftsContext.State.StarGift(
            gift: gift,
            reference: nil,
            fromPeer: nil,
            date: self.createdAt,
            text: nil,
            entities: nil,
            nameHidden: false,
            savedToProfile: self.visible,
            pinnedToTop: self.pinned || self.equipped,
            convertStars: nil,
            canUpgrade: false,
            canExportDate: nil,
            upgradeStars: nil,
            transferStars: nil,
            canTransferDate: nil,
            canResaleDate: nil,
            collectionIds: nil,
            prepaidUpgradeHash: nil,
            upgradeSeparate: false,
            dropOriginalDetailsStars: nil,
            number: self.number,
            isRefunded: false,
            canCraftAt: nil
        )
    }

    public static func imported(gift: StarGift) -> StuxnetLocalGift {
        switch gift {
        case let .generic(value):
            let color = value.background.map { UInt32(bitPattern: $0.edgeColor) } ?? 0x8b5cf6
            return StuxnetLocalGift(
                id: "telegram-gift-\(value.id)",
                title: value.title ?? "Star Gift",
                model: "Original",
                symbol: "🎁",
                color: color,
                number: nil,
                background: "Telegram",
                visible: true,
                pinned: false,
                sourceGift: gift
            )
        case let .unique(value):
            var model = "Unique"
            var symbol = "Collectible"
            var background = "Telegram"
            var color: UInt32 = 0x8b5cf6
            for attribute in value.attributes {
                switch attribute {
                case let .model(name, _, _, _):
                    model = name
                case let .pattern(name, _, _):
                    symbol = name
                case let .backdrop(name, _, _, outerColor, _, _, _):
                    background = name
                    color = UInt32(bitPattern: outerColor)
                case .originalInfo:
                    break
                }
            }
            return StuxnetLocalGift(
                id: "telegram-unique-\(value.id)-\(value.slug)",
                title: value.title,
                model: model,
                symbol: symbol,
                color: color,
                number: value.number,
                background: background,
                visible: true,
                pinned: false,
                sourceGift: gift,
                previewAttributes: value.attributes
            )
        }
    }

    public static let demoGifts: [StuxnetLocalGift] = [
        StuxnetLocalGift(id: "stuxnet-orchid", title: "Stuxnet Orchid", model: "Crystal", symbol: "✦", color: 0x8b5cf6, number: 1337, background: "Violet Aurora", visible: true, pinned: true),
        StuxnetLocalGift(id: "ghost-core", title: "Ghost Core", model: "Neon", symbol: "◈", color: 0x22d3ee, number: 404, background: "Ghost Grid", visible: true, pinned: false),
        StuxnetLocalGift(id: "ton-vault", title: "TON Vault", model: "Obsidian", symbol: "◆", color: 0x38bdf8, number: 777, background: "Deep Vault", visible: true, pinned: false)
    ]
}

public struct StuxnetSettings: Codable, Equatable {
    public var sendReadMessages: Bool
    public var sendReadStories: Bool
    public var sendOnlinePresence: Bool
    public var sendUploadProgress: Bool
    public var sendOfflineAfterOnline: Bool
    public var markReadAfterAction: Bool
    public var useScheduledMessagesInGhostMode: Bool
    public var ghostSendDelaySeconds: Int32
    public var saveDeletedMessages: Bool
    public var saveMessageHistory: Bool
    public var saveForBots: Bool
    public var showMessageDetails: Bool
    public var confirmMessageSending: Bool
    public var confirmMediaSending: Bool
    public var confirmChannelSubscriptions: Bool
    public var confirmCalls: Bool
    public var confirmStoryReplies: Bool
    public var confirmStoryReactions: Bool
    public var recordRoundVideosWithRearCamera: Bool
    public var voiceLabEnabled: Bool
    public var voiceLabPreset: String
    public var voiceLabPitchSemitones: Int32
    public var voiceLabTone: Int32
    public var voiceLabRobotMix: Int32
    public var voiceLabGainDb: Int32
    public var voiceLabApplyToVoiceMessages: Bool
    public var voiceLabApplyToRoundVideos: Bool
    public var voiceLabApplyToCalls: Bool
    public var deletedMessageLabel: String
    public var dimDeletedMessages: Bool
    public var localProfileEffects: Bool
    public var hidePhoneNumberLocally: Bool
    public var compactChatList: Bool
    public var hideChatListAvatars: Bool
    public var hideFastShareButton: Bool
    public var hideTypingActivity: Bool
    public var customMessageBubbleRadius: Int32?
    public var removeMessageTails: Bool
    public var showMessageSeconds: Bool
    public var showMessageDate: Bool
    public var showChatListSeconds: Bool
    public var showChatListDate: Bool
    public var useEnglishMonthNames: Bool
    public var localStarsBalance: Int64
    public var localTonBalanceNano: Int64
    public var localGifts: [StuxnetLocalGift]
    public var lockedPeerIds: [Int64]

    public static let defaultSettings = StuxnetSettings(
        sendReadMessages: true,
        sendReadStories: true,
        sendOnlinePresence: true,
        sendUploadProgress: true,
        sendOfflineAfterOnline: false,
        markReadAfterAction: true,
        useScheduledMessagesInGhostMode: true,
        ghostSendDelaySeconds: 12,
        saveDeletedMessages: true,
        saveMessageHistory: true,
        saveForBots: false,
        showMessageDetails: true,
        confirmMessageSending: false,
        confirmMediaSending: false,
        confirmChannelSubscriptions: false,
        confirmCalls: false,
        confirmStoryReplies: false,
        confirmStoryReactions: false,
        recordRoundVideosWithRearCamera: false,
        voiceLabEnabled: false,
        voiceLabPreset: "Natural",
        voiceLabPitchSemitones: 0,
        voiceLabTone: 0,
        voiceLabRobotMix: 0,
        voiceLabGainDb: 0,
        voiceLabApplyToVoiceMessages: true,
        voiceLabApplyToRoundVideos: true,
        voiceLabApplyToCalls: true,
        deletedMessageLabel: "⌫",
        dimDeletedMessages: true,
        localProfileEffects: false,
        hidePhoneNumberLocally: false,
        compactChatList: false,
        hideChatListAvatars: false,
        hideFastShareButton: false,
        hideTypingActivity: false,
        customMessageBubbleRadius: nil,
        removeMessageTails: false,
        showMessageSeconds: false,
        showMessageDate: false,
        showChatListSeconds: false,
        showChatListDate: false,
        useEnglishMonthNames: false,
        localStarsBalance: 0,
        localTonBalanceNano: 0,
        localGifts: [],
        lockedPeerIds: []
    )

    public var isGhostModeEnabled: Bool {
        return !self.sendReadMessages
            && !self.sendReadStories
            && !self.sendOnlinePresence
    }

    public init(
        sendReadMessages: Bool,
        sendReadStories: Bool,
        sendOnlinePresence: Bool,
        sendUploadProgress: Bool,
        sendOfflineAfterOnline: Bool,
        markReadAfterAction: Bool,
        useScheduledMessagesInGhostMode: Bool,
        ghostSendDelaySeconds: Int32,
        saveDeletedMessages: Bool,
        saveMessageHistory: Bool,
        saveForBots: Bool,
        showMessageDetails: Bool,
        confirmMessageSending: Bool,
        confirmMediaSending: Bool,
        confirmChannelSubscriptions: Bool,
        confirmCalls: Bool,
        confirmStoryReplies: Bool,
        confirmStoryReactions: Bool,
        recordRoundVideosWithRearCamera: Bool,
        voiceLabEnabled: Bool,
        voiceLabPreset: String,
        voiceLabPitchSemitones: Int32,
        voiceLabTone: Int32,
        voiceLabRobotMix: Int32,
        voiceLabGainDb: Int32,
        voiceLabApplyToVoiceMessages: Bool,
        voiceLabApplyToRoundVideos: Bool,
        voiceLabApplyToCalls: Bool,
        deletedMessageLabel: String,
        dimDeletedMessages: Bool,
        localProfileEffects: Bool,
        hidePhoneNumberLocally: Bool,
        compactChatList: Bool,
        hideChatListAvatars: Bool,
        hideFastShareButton: Bool,
        hideTypingActivity: Bool,
        customMessageBubbleRadius: Int32?,
        removeMessageTails: Bool,
        showMessageSeconds: Bool,
        showMessageDate: Bool,
        showChatListSeconds: Bool,
        showChatListDate: Bool,
        useEnglishMonthNames: Bool,
        localStarsBalance: Int64,
        localTonBalanceNano: Int64,
        localGifts: [StuxnetLocalGift],
        lockedPeerIds: [Int64]
    ) {
        self.sendReadMessages = sendReadMessages
        self.sendReadStories = sendReadStories
        self.sendOnlinePresence = sendOnlinePresence
        self.sendUploadProgress = sendUploadProgress
        self.sendOfflineAfterOnline = sendOfflineAfterOnline
        self.markReadAfterAction = markReadAfterAction
        self.useScheduledMessagesInGhostMode = useScheduledMessagesInGhostMode
        self.ghostSendDelaySeconds = ghostSendDelaySeconds
        self.saveDeletedMessages = saveDeletedMessages
        self.saveMessageHistory = saveMessageHistory
        self.saveForBots = saveForBots
        self.showMessageDetails = showMessageDetails
        self.confirmMessageSending = confirmMessageSending
        self.confirmMediaSending = confirmMediaSending
        self.confirmChannelSubscriptions = confirmChannelSubscriptions
        self.confirmCalls = confirmCalls
        self.confirmStoryReplies = confirmStoryReplies
        self.confirmStoryReactions = confirmStoryReactions
        self.recordRoundVideosWithRearCamera = recordRoundVideosWithRearCamera
        self.voiceLabEnabled = voiceLabEnabled
        self.voiceLabPreset = voiceLabPreset
        self.voiceLabPitchSemitones = voiceLabPitchSemitones
        self.voiceLabTone = voiceLabTone
        self.voiceLabRobotMix = voiceLabRobotMix
        self.voiceLabGainDb = voiceLabGainDb
        self.voiceLabApplyToVoiceMessages = voiceLabApplyToVoiceMessages
        self.voiceLabApplyToRoundVideos = voiceLabApplyToRoundVideos
        self.voiceLabApplyToCalls = voiceLabApplyToCalls
        self.deletedMessageLabel = deletedMessageLabel
        self.dimDeletedMessages = dimDeletedMessages
        self.localProfileEffects = localProfileEffects
        self.hidePhoneNumberLocally = hidePhoneNumberLocally
        self.compactChatList = compactChatList
        self.hideChatListAvatars = hideChatListAvatars
        self.hideFastShareButton = hideFastShareButton
        self.hideTypingActivity = hideTypingActivity
        self.customMessageBubbleRadius = customMessageBubbleRadius
        self.removeMessageTails = removeMessageTails
        self.showMessageSeconds = showMessageSeconds
        self.showMessageDate = showMessageDate
        self.showChatListSeconds = showChatListSeconds
        self.showChatListDate = showChatListDate
        self.useEnglishMonthNames = useEnglishMonthNames
        self.localStarsBalance = localStarsBalance
        self.localTonBalanceNano = localTonBalanceNano
        self.localGifts = localGifts
        self.lockedPeerIds = lockedPeerIds
    }

    private enum CodingKeys: String, CodingKey {
        case sendReadMessages
        case sendReadStories
        case sendOnlinePresence
        case sendUploadProgress
        case sendOfflineAfterOnline
        case markReadAfterAction
        case useScheduledMessagesInGhostMode
        case ghostSendDelaySeconds
        case saveDeletedMessages
        case saveMessageHistory
        case saveForBots
        case showMessageDetails
        case confirmMessageSending
        case confirmMediaSending
        case confirmChannelSubscriptions
        case confirmCalls
        case confirmStoryReplies
        case confirmStoryReactions
        case recordRoundVideosWithRearCamera
        case voiceLabEnabled
        case voiceLabPreset
        case voiceLabPitchSemitones
        case voiceLabTone
        case voiceLabRobotMix
        case voiceLabGainDb
        case voiceLabApplyToVoiceMessages
        case voiceLabApplyToRoundVideos
        case voiceLabApplyToCalls
        case deletedMessageLabel
        case dimDeletedMessages
        case localProfileEffects
        case hidePhoneNumberLocally
        case compactChatList
        case hideChatListAvatars
        case hideFastShareButton
        case hideTypingActivity
        case customMessageBubbleRadius
        case removeMessageTails
        case showMessageSeconds
        case showMessageDate
        case showChatListSeconds
        case showChatListDate
        case useEnglishMonthNames
        case localStarsBalance
        case localTonBalanceNano
        case localGifts
        case lockedPeerIds
    }

    public init(from decoder: Decoder) throws {
        let defaults = StuxnetSettings.defaultSettings
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sendReadMessages = try container.decodeIfPresent(Bool.self, forKey: .sendReadMessages) ?? defaults.sendReadMessages
        self.sendReadStories = try container.decodeIfPresent(Bool.self, forKey: .sendReadStories) ?? defaults.sendReadStories
        self.sendOnlinePresence = try container.decodeIfPresent(Bool.self, forKey: .sendOnlinePresence) ?? defaults.sendOnlinePresence
        self.sendUploadProgress = try container.decodeIfPresent(Bool.self, forKey: .sendUploadProgress) ?? defaults.sendUploadProgress
        self.sendOfflineAfterOnline = try container.decodeIfPresent(Bool.self, forKey: .sendOfflineAfterOnline) ?? defaults.sendOfflineAfterOnline
        self.markReadAfterAction = try container.decodeIfPresent(Bool.self, forKey: .markReadAfterAction) ?? defaults.markReadAfterAction
        self.useScheduledMessagesInGhostMode = try container.decodeIfPresent(Bool.self, forKey: .useScheduledMessagesInGhostMode) ?? defaults.useScheduledMessagesInGhostMode
        self.ghostSendDelaySeconds = min(60, max(10, try container.decodeIfPresent(Int32.self, forKey: .ghostSendDelaySeconds) ?? defaults.ghostSendDelaySeconds))
        self.saveDeletedMessages = try container.decodeIfPresent(Bool.self, forKey: .saveDeletedMessages) ?? defaults.saveDeletedMessages
        self.saveMessageHistory = try container.decodeIfPresent(Bool.self, forKey: .saveMessageHistory) ?? defaults.saveMessageHistory
        self.saveForBots = try container.decodeIfPresent(Bool.self, forKey: .saveForBots) ?? defaults.saveForBots
        self.showMessageDetails = try container.decodeIfPresent(Bool.self, forKey: .showMessageDetails) ?? defaults.showMessageDetails
        self.confirmMessageSending = try container.decodeIfPresent(Bool.self, forKey: .confirmMessageSending) ?? defaults.confirmMessageSending
        self.confirmMediaSending = try container.decodeIfPresent(Bool.self, forKey: .confirmMediaSending) ?? defaults.confirmMediaSending
        self.confirmChannelSubscriptions = try container.decodeIfPresent(Bool.self, forKey: .confirmChannelSubscriptions) ?? defaults.confirmChannelSubscriptions
        self.confirmCalls = try container.decodeIfPresent(Bool.self, forKey: .confirmCalls) ?? defaults.confirmCalls
        self.confirmStoryReplies = try container.decodeIfPresent(Bool.self, forKey: .confirmStoryReplies) ?? defaults.confirmStoryReplies
        self.confirmStoryReactions = try container.decodeIfPresent(Bool.self, forKey: .confirmStoryReactions) ?? defaults.confirmStoryReactions
        self.recordRoundVideosWithRearCamera = try container.decodeIfPresent(Bool.self, forKey: .recordRoundVideosWithRearCamera) ?? defaults.recordRoundVideosWithRearCamera
        self.voiceLabEnabled = try container.decodeIfPresent(Bool.self, forKey: .voiceLabEnabled) ?? defaults.voiceLabEnabled
        self.voiceLabPreset = try container.decodeIfPresent(String.self, forKey: .voiceLabPreset) ?? defaults.voiceLabPreset
        self.voiceLabPitchSemitones = min(12, max(-12, try container.decodeIfPresent(Int32.self, forKey: .voiceLabPitchSemitones) ?? defaults.voiceLabPitchSemitones))
        self.voiceLabTone = min(100, max(-100, try container.decodeIfPresent(Int32.self, forKey: .voiceLabTone) ?? defaults.voiceLabTone))
        self.voiceLabRobotMix = min(100, max(0, try container.decodeIfPresent(Int32.self, forKey: .voiceLabRobotMix) ?? defaults.voiceLabRobotMix))
        self.voiceLabGainDb = min(12, max(-12, try container.decodeIfPresent(Int32.self, forKey: .voiceLabGainDb) ?? defaults.voiceLabGainDb))
        self.voiceLabApplyToVoiceMessages = try container.decodeIfPresent(Bool.self, forKey: .voiceLabApplyToVoiceMessages) ?? defaults.voiceLabApplyToVoiceMessages
        self.voiceLabApplyToRoundVideos = try container.decodeIfPresent(Bool.self, forKey: .voiceLabApplyToRoundVideos) ?? defaults.voiceLabApplyToRoundVideos
        self.voiceLabApplyToCalls = try container.decodeIfPresent(Bool.self, forKey: .voiceLabApplyToCalls) ?? defaults.voiceLabApplyToCalls
        let decodedDeletedMessageLabel = try container.decodeIfPresent(String.self, forKey: .deletedMessageLabel) ?? defaults.deletedMessageLabel
        self.deletedMessageLabel = decodedDeletedMessageLabel == "Deleted" ? "⌫" : String(decodedDeletedMessageLabel.prefix(24))
        self.dimDeletedMessages = try container.decodeIfPresent(Bool.self, forKey: .dimDeletedMessages) ?? defaults.dimDeletedMessages
        self.localProfileEffects = try container.decodeIfPresent(Bool.self, forKey: .localProfileEffects) ?? defaults.localProfileEffects
        self.hidePhoneNumberLocally = try container.decodeIfPresent(Bool.self, forKey: .hidePhoneNumberLocally) ?? defaults.hidePhoneNumberLocally
        self.compactChatList = try container.decodeIfPresent(Bool.self, forKey: .compactChatList) ?? defaults.compactChatList
        self.hideChatListAvatars = try container.decodeIfPresent(Bool.self, forKey: .hideChatListAvatars) ?? defaults.hideChatListAvatars
        self.hideFastShareButton = try container.decodeIfPresent(Bool.self, forKey: .hideFastShareButton) ?? defaults.hideFastShareButton
        self.hideTypingActivity = try container.decodeIfPresent(Bool.self, forKey: .hideTypingActivity) ?? defaults.hideTypingActivity
        self.customMessageBubbleRadius = try container.decodeIfPresent(Int32.self, forKey: .customMessageBubbleRadius).map { min(16, max(8, $0)) }
        self.removeMessageTails = try container.decodeIfPresent(Bool.self, forKey: .removeMessageTails) ?? defaults.removeMessageTails
        self.showMessageSeconds = try container.decodeIfPresent(Bool.self, forKey: .showMessageSeconds) ?? defaults.showMessageSeconds
        self.showMessageDate = try container.decodeIfPresent(Bool.self, forKey: .showMessageDate) ?? defaults.showMessageDate
        self.showChatListSeconds = try container.decodeIfPresent(Bool.self, forKey: .showChatListSeconds) ?? defaults.showChatListSeconds
        self.showChatListDate = try container.decodeIfPresent(Bool.self, forKey: .showChatListDate) ?? defaults.showChatListDate
        self.useEnglishMonthNames = try container.decodeIfPresent(Bool.self, forKey: .useEnglishMonthNames) ?? defaults.useEnglishMonthNames
        self.localStarsBalance = max(0, try container.decodeIfPresent(Int64.self, forKey: .localStarsBalance) ?? defaults.localStarsBalance)
        self.localTonBalanceNano = max(0, try container.decodeIfPresent(Int64.self, forKey: .localTonBalanceNano) ?? defaults.localTonBalanceNano)
        self.localGifts = try container.decodeIfPresent([StuxnetLocalGift].self, forKey: .localGifts) ?? defaults.localGifts
        self.lockedPeerIds = Array(Set(try container.decodeIfPresent([Int64].self, forKey: .lockedPeerIds) ?? defaults.lockedPeerIds)).sorted()
    }

    public func withUpdatedGhostMode(_ value: Bool) -> StuxnetSettings {
        var updated = self
        updated.sendReadMessages = !value
        updated.sendReadStories = !value
        updated.sendOnlinePresence = !value
        updated.sendUploadProgress = !value
        updated.hideTypingActivity = value
        updated.sendOfflineAfterOnline = value
        return updated
    }

    public func isChatLocked(_ peerId: PeerId) -> Bool {
        return self.lockedPeerIds.contains(peerId.toInt64())
    }

    public func withUpdatedChatLocked(peerId: PeerId, value: Bool) -> StuxnetSettings {
        var updated = self
        let valueId = peerId.toInt64()
        var ids = Set(updated.lockedPeerIds)
        if value {
            ids.insert(valueId)
        } else {
            ids.remove(valueId)
        }
        updated.lockedPeerIds = Array(ids).sorted()
        return updated
    }
}

public func stuxnetSettings(transaction: Transaction) -> StuxnetSettings {
    return transaction.getPreferencesEntry(key: PreferencesKeys.stuxnetSettings)?.get(StuxnetSettings.self) ?? .defaultSettings
}

public func stuxnetSettings(postbox: Postbox) -> Signal<StuxnetSettings, NoError> {
    return postbox.preferencesView(keys: [PreferencesKeys.stuxnetSettings])
    |> map { view -> StuxnetSettings in
        return view.values[PreferencesKeys.stuxnetSettings]?.get(StuxnetSettings.self) ?? .defaultSettings
    }
    |> distinctUntilChanged
}

public func updateStuxnetSettings(transaction: Transaction, _ f: (StuxnetSettings) -> StuxnetSettings) {
    transaction.updatePreferencesEntry(key: PreferencesKeys.stuxnetSettings, { current in
        let previous = current?.get(StuxnetSettings.self) ?? .defaultSettings
        return PreferencesEntry(f(previous))
    })
}

public func updateStuxnetSettingsInteractively(postbox: Postbox, _ f: @escaping (StuxnetSettings) -> StuxnetSettings) -> Signal<Never, NoError> {
    return postbox.transaction { transaction -> Void in
        updateStuxnetSettings(transaction: transaction, f)
    }
    |> ignoreValues
}
