import Foundation
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import AccountContext

private final class StuxnetSettingsControllerArguments {
    let updateGhostMode: (Bool) -> Void
    let openGhostMode: () -> Void
    let updateSendReadMessages: (Bool) -> Void
    let updateSendReadStories: (Bool) -> Void
    let updateSendOnlinePresence: (Bool) -> Void
    let updateSendUploadProgress: (Bool) -> Void
    let updateSendOfflineAfterOnline: (Bool) -> Void
    let updateMarkReadAfterAction: (Bool) -> Void
    let updateUseScheduledMessagesInGhostMode: (Bool) -> Void
    let updateGhostSendDelaySeconds: (String) -> Void
    let updateSaveDeletedMessages: (Bool) -> Void
    let updateSaveMessageHistory: (Bool) -> Void
    let updateSaveForBots: (Bool) -> Void
    let updateShowMessageDetails: (Bool) -> Void
    let updateConfirmMessageSending: (Bool) -> Void
    let updateConfirmMediaSending: (Bool) -> Void
    let updateConfirmChannelSubscriptions: (Bool) -> Void
    let updateConfirmCalls: (Bool) -> Void
    let updateConfirmStoryReplies: (Bool) -> Void
    let updateConfirmStoryReactions: (Bool) -> Void
    let updateRecordRoundVideosWithRearCamera: (Bool) -> Void
    let updateVoiceLabEnabled: (Bool) -> Void
    let cycleVoiceLabPreset: () -> Void
    let updateVoiceLabPitchSemitones: (String) -> Void
    let updateVoiceLabTone: (String) -> Void
    let updateVoiceLabRobotMix: (String) -> Void
    let updateVoiceLabGainDb: (String) -> Void
    let updateVoiceLabApplyToVoiceMessages: (Bool) -> Void
    let updateVoiceLabApplyToRoundVideos: (Bool) -> Void
    let updateVoiceLabApplyToCalls: (Bool) -> Void
    let updateDeletedMessageLabel: (String) -> Void
    let updateDimDeletedMessages: (Bool) -> Void
    let updateLocalProfileEffects: (Bool) -> Void
    let updateHidePhoneNumberLocally: (Bool) -> Void
    let updateCompactChatList: (Bool) -> Void
    let updateShowMessageSeconds: (Bool) -> Void
    let updateShowMessageDate: (Bool) -> Void
    let updateShowChatListSeconds: (Bool) -> Void
    let updateShowChatListDate: (Bool) -> Void
    let updateUseEnglishMonthNames: (Bool) -> Void
    let openChatsAppearance: () -> Void
    let updateLocalStarsBalance: (String) -> Void
    let updateLocalTonBalance: (String) -> Void
    let openGifts: () -> Void
    let installDemoGifts: () -> Void
    let updateFeaturedGiftTitle: (String) -> Void
    let updateFeaturedGiftModel: (String) -> Void
    let updateFeaturedGiftSymbol: (String) -> Void
    let updateFeaturedGiftNumber: (String) -> Void
    let updateFeaturedGiftBackground: (String) -> Void
    let updateFeaturedGiftColor: (String) -> Void
    let updateFeaturedGiftVisible: (Bool) -> Void
    let updateFeaturedGiftPinned: (Bool) -> Void
    let clearLocalGifts: () -> Void

    init(
        updateGhostMode: @escaping (Bool) -> Void,
        openGhostMode: @escaping () -> Void,
        updateSendReadMessages: @escaping (Bool) -> Void,
        updateSendReadStories: @escaping (Bool) -> Void,
        updateSendOnlinePresence: @escaping (Bool) -> Void,
        updateSendUploadProgress: @escaping (Bool) -> Void,
        updateSendOfflineAfterOnline: @escaping (Bool) -> Void,
        updateMarkReadAfterAction: @escaping (Bool) -> Void,
        updateUseScheduledMessagesInGhostMode: @escaping (Bool) -> Void,
        updateGhostSendDelaySeconds: @escaping (String) -> Void,
        updateSaveDeletedMessages: @escaping (Bool) -> Void,
        updateSaveMessageHistory: @escaping (Bool) -> Void,
        updateSaveForBots: @escaping (Bool) -> Void,
        updateShowMessageDetails: @escaping (Bool) -> Void,
        updateConfirmMessageSending: @escaping (Bool) -> Void,
        updateConfirmMediaSending: @escaping (Bool) -> Void,
        updateConfirmChannelSubscriptions: @escaping (Bool) -> Void,
        updateConfirmCalls: @escaping (Bool) -> Void,
        updateConfirmStoryReplies: @escaping (Bool) -> Void,
        updateConfirmStoryReactions: @escaping (Bool) -> Void,
        updateRecordRoundVideosWithRearCamera: @escaping (Bool) -> Void,
        updateVoiceLabEnabled: @escaping (Bool) -> Void,
        cycleVoiceLabPreset: @escaping () -> Void,
        updateVoiceLabPitchSemitones: @escaping (String) -> Void,
        updateVoiceLabTone: @escaping (String) -> Void,
        updateVoiceLabRobotMix: @escaping (String) -> Void,
        updateVoiceLabGainDb: @escaping (String) -> Void,
        updateVoiceLabApplyToVoiceMessages: @escaping (Bool) -> Void,
        updateVoiceLabApplyToRoundVideos: @escaping (Bool) -> Void,
        updateVoiceLabApplyToCalls: @escaping (Bool) -> Void,
        updateDeletedMessageLabel: @escaping (String) -> Void,
        updateDimDeletedMessages: @escaping (Bool) -> Void,
        updateLocalProfileEffects: @escaping (Bool) -> Void,
        updateHidePhoneNumberLocally: @escaping (Bool) -> Void,
        updateCompactChatList: @escaping (Bool) -> Void,
        updateShowMessageSeconds: @escaping (Bool) -> Void,
        updateShowMessageDate: @escaping (Bool) -> Void,
        updateShowChatListSeconds: @escaping (Bool) -> Void,
        updateShowChatListDate: @escaping (Bool) -> Void,
        updateUseEnglishMonthNames: @escaping (Bool) -> Void,
        openChatsAppearance: @escaping () -> Void,
        updateLocalStarsBalance: @escaping (String) -> Void,
        updateLocalTonBalance: @escaping (String) -> Void,
        openGifts: @escaping () -> Void,
        installDemoGifts: @escaping () -> Void,
        updateFeaturedGiftTitle: @escaping (String) -> Void,
        updateFeaturedGiftModel: @escaping (String) -> Void,
        updateFeaturedGiftSymbol: @escaping (String) -> Void,
        updateFeaturedGiftNumber: @escaping (String) -> Void,
        updateFeaturedGiftBackground: @escaping (String) -> Void,
        updateFeaturedGiftColor: @escaping (String) -> Void,
        updateFeaturedGiftVisible: @escaping (Bool) -> Void,
        updateFeaturedGiftPinned: @escaping (Bool) -> Void,
        clearLocalGifts: @escaping () -> Void
    ) {
        self.updateGhostMode = updateGhostMode
        self.openGhostMode = openGhostMode
        self.updateSendReadMessages = updateSendReadMessages
        self.updateSendReadStories = updateSendReadStories
        self.updateSendOnlinePresence = updateSendOnlinePresence
        self.updateSendUploadProgress = updateSendUploadProgress
        self.updateSendOfflineAfterOnline = updateSendOfflineAfterOnline
        self.updateMarkReadAfterAction = updateMarkReadAfterAction
        self.updateUseScheduledMessagesInGhostMode = updateUseScheduledMessagesInGhostMode
        self.updateGhostSendDelaySeconds = updateGhostSendDelaySeconds
        self.updateSaveDeletedMessages = updateSaveDeletedMessages
        self.updateSaveMessageHistory = updateSaveMessageHistory
        self.updateSaveForBots = updateSaveForBots
        self.updateShowMessageDetails = updateShowMessageDetails
        self.updateConfirmMessageSending = updateConfirmMessageSending
        self.updateConfirmMediaSending = updateConfirmMediaSending
        self.updateConfirmChannelSubscriptions = updateConfirmChannelSubscriptions
        self.updateConfirmCalls = updateConfirmCalls
        self.updateConfirmStoryReplies = updateConfirmStoryReplies
        self.updateConfirmStoryReactions = updateConfirmStoryReactions
        self.updateRecordRoundVideosWithRearCamera = updateRecordRoundVideosWithRearCamera
        self.updateVoiceLabEnabled = updateVoiceLabEnabled
        self.cycleVoiceLabPreset = cycleVoiceLabPreset
        self.updateVoiceLabPitchSemitones = updateVoiceLabPitchSemitones
        self.updateVoiceLabTone = updateVoiceLabTone
        self.updateVoiceLabRobotMix = updateVoiceLabRobotMix
        self.updateVoiceLabGainDb = updateVoiceLabGainDb
        self.updateVoiceLabApplyToVoiceMessages = updateVoiceLabApplyToVoiceMessages
        self.updateVoiceLabApplyToRoundVideos = updateVoiceLabApplyToRoundVideos
        self.updateVoiceLabApplyToCalls = updateVoiceLabApplyToCalls
        self.updateDeletedMessageLabel = updateDeletedMessageLabel
        self.updateDimDeletedMessages = updateDimDeletedMessages
        self.updateLocalProfileEffects = updateLocalProfileEffects
        self.updateHidePhoneNumberLocally = updateHidePhoneNumberLocally
        self.updateCompactChatList = updateCompactChatList
        self.updateShowMessageSeconds = updateShowMessageSeconds
        self.updateShowMessageDate = updateShowMessageDate
        self.updateShowChatListSeconds = updateShowChatListSeconds
        self.updateShowChatListDate = updateShowChatListDate
        self.updateUseEnglishMonthNames = updateUseEnglishMonthNames
        self.openChatsAppearance = openChatsAppearance
        self.updateLocalStarsBalance = updateLocalStarsBalance
        self.updateLocalTonBalance = updateLocalTonBalance
        self.openGifts = openGifts
        self.installDemoGifts = installDemoGifts
        self.updateFeaturedGiftTitle = updateFeaturedGiftTitle
        self.updateFeaturedGiftModel = updateFeaturedGiftModel
        self.updateFeaturedGiftSymbol = updateFeaturedGiftSymbol
        self.updateFeaturedGiftNumber = updateFeaturedGiftNumber
        self.updateFeaturedGiftBackground = updateFeaturedGiftBackground
        self.updateFeaturedGiftColor = updateFeaturedGiftColor
        self.updateFeaturedGiftVisible = updateFeaturedGiftVisible
        self.updateFeaturedGiftPinned = updateFeaturedGiftPinned
        self.clearLocalGifts = clearLocalGifts
    }
}

private enum StuxnetSettingsSection: Int32 {
    case ghost
    case ghostDetails
    case messages
    case confirmations
    case voiceLab
    case appearance
    case profile
}

private enum StuxnetSettingsEntry: ItemListNodeEntry {
    case ghostHeader
    case ghostMode(Bool)
    case ghostControls(String)
    case ghostInfo
    case ghostDetailsHeader
    case sendReadMessages(Bool)
    case sendReadStories(Bool)
    case sendOnlinePresence(Bool)
    case sendUploadProgress(Bool)
    case sendOfflineAfterOnline(Bool)
    case markReadAfterAction(Bool)
    case useScheduledMessagesInGhostMode(Bool)
    case ghostSendDelaySeconds(String)
    case ghostDetailsInfo
    case messagesHeader
    case saveDeletedMessages(Bool)
    case saveMessageHistory(Bool)
    case saveForBots(Bool)
    case showMessageDetails(Bool)
    case confirmMessageSending(Bool)
    case confirmMediaSending(Bool)
    case confirmChannelSubscriptions(Bool)
    case confirmCalls(Bool)
    case confirmStoryReplies(Bool)
    case confirmStoryReactions(Bool)
    case deletedMessageLabel(String)
    case dimDeletedMessages(Bool)
    case messagesInfo
    case confirmationsHeader
    case voiceLabHeader
    case voiceLabEnabled(Bool)
    case voiceLabPreset(String)
    case voiceLabPitchSemitones(String)
    case voiceLabTone(String)
    case voiceLabRobotMix(String)
    case voiceLabGainDb(String)
    case voiceLabApplyToVoiceMessages(Bool)
    case voiceLabApplyToRoundVideos(Bool)
    case voiceLabApplyToCalls(Bool)
    case recordRoundVideosWithRearCamera(Bool)
    case voiceLabInfo
    case appearanceHeader
    case chatsAppearance
    case compactChatList(Bool)
    case showMessageSeconds(Bool)
    case showMessageDate(Bool)
    case showChatListSeconds(Bool)
    case showChatListDate(Bool)
    case useEnglishMonthNames(Bool)
    case appearanceInfo
    case profileHeader
    case localProfileEffects(Bool)
    case hidePhoneNumberLocally(Bool)
    case localStarsBalance(String)
    case localTonBalance(String)
    case manageGifts(Int)
    case installDemoGifts(Int)
    case featuredGiftInfo(String)
    case featuredGiftTitle(String)
    case featuredGiftModel(String)
    case featuredGiftSymbol(String)
    case featuredGiftNumber(String)
    case featuredGiftBackground(String)
    case featuredGiftColor(String)
    case featuredGiftVisible(Bool)
    case featuredGiftPinned(Bool)
    case clearLocalGifts
    case profileInfo

    var section: ItemListSectionId {
        switch self {
        case .ghostHeader, .ghostMode, .ghostControls, .ghostInfo:
            return StuxnetSettingsSection.ghost.rawValue
        case .ghostDetailsHeader, .sendReadMessages, .sendReadStories, .sendOnlinePresence, .sendUploadProgress, .sendOfflineAfterOnline, .markReadAfterAction, .useScheduledMessagesInGhostMode, .ghostSendDelaySeconds, .ghostDetailsInfo:
            return StuxnetSettingsSection.ghostDetails.rawValue
        case .messagesHeader, .saveDeletedMessages, .saveMessageHistory, .saveForBots, .showMessageDetails, .deletedMessageLabel, .dimDeletedMessages, .messagesInfo:
            return StuxnetSettingsSection.messages.rawValue
        case .confirmationsHeader, .confirmMessageSending, .confirmMediaSending, .confirmChannelSubscriptions, .confirmCalls, .confirmStoryReplies, .confirmStoryReactions:
            return StuxnetSettingsSection.confirmations.rawValue
        case .voiceLabHeader, .voiceLabEnabled, .voiceLabPreset, .voiceLabPitchSemitones, .voiceLabTone, .voiceLabRobotMix, .voiceLabGainDb, .voiceLabApplyToVoiceMessages, .voiceLabApplyToRoundVideos, .voiceLabApplyToCalls, .recordRoundVideosWithRearCamera, .voiceLabInfo:
            return StuxnetSettingsSection.voiceLab.rawValue
        case .appearanceHeader, .chatsAppearance, .compactChatList, .showMessageSeconds, .showMessageDate, .showChatListSeconds, .showChatListDate, .useEnglishMonthNames, .appearanceInfo:
            return StuxnetSettingsSection.appearance.rawValue
        case .profileHeader, .localProfileEffects, .hidePhoneNumberLocally, .localStarsBalance, .localTonBalance, .manageGifts, .installDemoGifts, .featuredGiftInfo, .featuredGiftTitle, .featuredGiftModel, .featuredGiftSymbol, .featuredGiftNumber, .featuredGiftBackground, .featuredGiftColor, .featuredGiftVisible, .featuredGiftPinned, .clearLocalGifts, .profileInfo:
            return StuxnetSettingsSection.profile.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .ghostHeader: return 0
        case .ghostMode: return 1
        case .ghostControls: return 2
        case .ghostInfo: return 3
        case .ghostDetailsHeader: return 10
        case .sendReadMessages: return 11
        case .sendReadStories: return 12
        case .sendOnlinePresence: return 13
        case .sendUploadProgress: return 14
        case .sendOfflineAfterOnline: return 15
        case .markReadAfterAction: return 16
        case .useScheduledMessagesInGhostMode: return 17
        case .ghostSendDelaySeconds: return 18
        case .ghostDetailsInfo: return 19
        case .messagesHeader: return 20
        case .saveDeletedMessages: return 21
        case .saveMessageHistory: return 22
        case .saveForBots: return 23
        case .showMessageDetails: return 24
        case .deletedMessageLabel: return 25
        case .dimDeletedMessages: return 26
        case .messagesInfo: return 27
        case .confirmationsHeader: return 28
        case .confirmMessageSending: return 29
        case .confirmMediaSending: return 30
        case .confirmChannelSubscriptions: return 31
        case .confirmCalls: return 32
        case .confirmStoryReplies: return 33
        case .confirmStoryReactions: return 34
        case .voiceLabHeader: return 35
        case .voiceLabEnabled: return 36
        case .voiceLabPreset: return 37
        case .voiceLabPitchSemitones: return 38
        case .voiceLabTone: return 39
        case .voiceLabRobotMix: return 40
        case .voiceLabGainDb: return 41
        case .voiceLabApplyToVoiceMessages: return 42
        case .voiceLabApplyToRoundVideos: return 43
        case .voiceLabApplyToCalls: return 44
        case .recordRoundVideosWithRearCamera: return 45
        case .voiceLabInfo: return 46
        case .appearanceHeader: return 47
        case .chatsAppearance: return 48
        case .compactChatList: return 49
        case .showMessageSeconds: return 50
        case .showMessageDate: return 51
        case .showChatListSeconds: return 52
        case .showChatListDate: return 53
        case .useEnglishMonthNames: return 54
        case .appearanceInfo: return 55
        case .profileHeader: return 56
        case .localProfileEffects: return 57
        case .hidePhoneNumberLocally: return 58
        case .localStarsBalance: return 59
        case .localTonBalance: return 60
        case .manageGifts: return 61
        case .installDemoGifts: return 62
        case .featuredGiftInfo: return 63
        case .featuredGiftTitle: return 64
        case .featuredGiftModel: return 65
        case .featuredGiftSymbol: return 66
        case .featuredGiftNumber: return 67
        case .featuredGiftBackground: return 68
        case .featuredGiftColor: return 69
        case .featuredGiftVisible: return 70
        case .featuredGiftPinned: return 71
        case .clearLocalGifts: return 72
        case .profileInfo: return 73
        }
    }

    static func < (lhs: StuxnetSettingsEntry, rhs: StuxnetSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! StuxnetSettingsControllerArguments
        switch self {
        case .ghostHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "STEALTH", sectionId: self.section)
        case let .ghostMode(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Ghost Mode", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateGhostMode)
        case let .ghostControls(value):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Ghost Mode", label: value, labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.openGhostMode)
        case .ghostInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Read receipts, story views, presence, typing and the delayed-send queue are now grouped on one account-specific screen."), sectionId: self.section)
        case .ghostDetailsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "GHOST MODE DETAILS", sectionId: self.section)
        case let .sendReadMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Send message read receipts", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSendReadMessages)
        case let .sendReadStories(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Send story views", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSendReadStories)
        case let .sendOnlinePresence(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Send online presence", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSendOnlinePresence)
        case let .sendUploadProgress(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Send upload progress", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSendUploadProgress)
        case let .sendOfflineAfterOnline(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Send offline when hiding", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSendOfflineAfterOnline)
        case let .markReadAfterAction(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Mark read after reactions and poll votes", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateMarkReadAfterAction)
        case let .useScheduledMessagesInGhostMode(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Queue sends with Telegram Schedule", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateUseScheduledMessagesInGhostMode)
        case let .ghostSendDelaySeconds(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Send delay", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "12", type: .number, spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateGhostSendDelaySeconds, action: {})
        case .ghostDetailsInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Opening a chat still clears its unread badge locally, but disabled receipts are not sent to Telegram. Reactions and poll votes can optionally reveal the read state, matching AyuGram. Queue sends creates a normal Telegram scheduled message for 10–60 seconds, so it can be edited or cancelled from Scheduled Messages."), sectionId: self.section)
        case .messagesHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "MESSAGE HISTORY", sectionId: self.section)
        case let .saveDeletedMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Keep deleted messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSaveDeletedMessages)
        case let .saveMessageHistory(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Keep edit history", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSaveMessageHistory)
        case let .saveForBots(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Keep history in bot chats", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSaveForBots)
        case let .showMessageDetails(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Message details action", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowMessageDetails)
        case let .confirmMessageSending(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Confirm text messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateConfirmMessageSending)
        case let .confirmMediaSending(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Confirm media and files", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateConfirmMediaSending)
        case let .confirmChannelSubscriptions(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Confirm channel subscriptions", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateConfirmChannelSubscriptions)
        case let .confirmCalls(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Confirm outgoing calls", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateConfirmCalls)
        case let .confirmStoryReplies(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Confirm story replies", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateConfirmStoryReplies)
        case let .confirmStoryReactions(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Confirm story reactions", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateConfirmStoryReactions)
        case let .deletedMessageLabel(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Deleted marker", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "⌫", type: .regular(capitalization: true, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateDeletedMessageLabel, action: {})
        case let .dimDeletedMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Dim deleted messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateDimDeletedMessages)
        case .messagesInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Messages already received by this device are preserved when delete updates arrive immediately or after the app is reopened, including channel validation, minimum-history updates, TTL cleanup and secret-chat clears. Messages deleted before Telegram ever delivers their contents cannot be reconstructed. Edit revisions and message details remain local to this account."), sectionId: self.section)
        case .confirmationsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ACTION CONFIRMATIONS", sectionId: self.section)
        case .voiceLabHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "VOICE & CAMERA", sectionId: self.section)
        case let .voiceLabEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Voice Lab", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateVoiceLabEnabled)
        case let .voiceLabPreset(value):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Voice preset", label: value, labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.cycleVoiceLabPreset)
        case let .voiceLabPitchSemitones(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Pitch", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "-12…12", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateVoiceLabPitchSemitones, action: {})
        case let .voiceLabTone(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Tone", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "-100…100", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateVoiceLabTone, action: {})
        case let .voiceLabRobotMix(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Robot mix", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "0…100", type: .number, spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateVoiceLabRobotMix, action: {})
        case let .voiceLabGainDb(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Gain, dB", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "-12…12", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateVoiceLabGainDb, action: {})
        case let .voiceLabApplyToVoiceMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Apply to voice messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateVoiceLabApplyToVoiceMessages)
        case let .voiceLabApplyToRoundVideos(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Apply to round videos", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateVoiceLabApplyToRoundVideos)
        case let .voiceLabApplyToCalls(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Apply to calls and voice chats", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateVoiceLabApplyToCalls)
        case let .recordRoundVideosWithRearCamera(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Start round videos with rear camera", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateRecordRoundVideosWithRearCamera)
        case .voiceLabInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Voice Lab processes outgoing PCM before Telegram encodes voice messages, story voice replies, round videos, calls and voice chats. Each destination can be disabled independently. Anonymous presets add time-varying and nonlinear privacy masking, but no filter can guarantee anonymity against every analysis method."), sectionId: self.section)
        case .appearanceHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "APPEARANCE", sectionId: self.section)
        case .chatsAppearance:
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Chats & Appearance", label: "Live preview", labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.openChatsAppearance)
        case let .compactChatList(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Compact chat list", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateCompactChatList)
        case let .showMessageSeconds(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Seconds in messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowMessageSeconds)
        case let .showMessageDate(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Date in message timestamps", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowMessageDate)
        case let .showChatListSeconds(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Seconds in chat list", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowChatListSeconds)
        case let .showChatListDate(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Date in chat list", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowChatListDate)
        case let .useEnglishMonthNames(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "English short months", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateUseEnglishMonthNames)
        case .appearanceInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Open the visual lab for a native Telegram message preview, bubble geometry, compact chat-list controls, detailed timestamps and activity privacy."), sectionId: self.section)
        case .profileHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "PROFILE", sectionId: self.section)
        case let .localProfileEffects(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Profile decorations", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateLocalProfileEffects)
        case let .hidePhoneNumberLocally(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide phone numbers locally", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHidePhoneNumberLocally)
        case let .localStarsBalance(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Local Stars", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "0", type: .number, spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateLocalStarsBalance, action: {})
        case let .localTonBalance(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Local TON", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "0.0", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateLocalTonBalance, action: {})
        case let .manageGifts(count):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Gifts", label: count == 0 ? "Add from Telegram catalog" : "\(count) in collection", labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.openGifts)
        case let .installDemoGifts(count):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: count == 0 ? "Install Stuxnet gift set" : "Reset Stuxnet gift set (\(count))", kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.installDemoGifts)
        case let .featuredGiftInfo(value):
            return ItemListTextItem(presentationData: presentationData, text: .plain("FEATURED GIFT · \(value)"), sectionId: self.section)
        case let .featuredGiftTitle(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Gift title", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "Local gift", type: .regular(capitalization: true, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateFeaturedGiftTitle, action: {})
        case let .featuredGiftModel(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Model", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "Crystal", type: .regular(capitalization: true, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateFeaturedGiftModel, action: {})
        case let .featuredGiftSymbol(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Symbol", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "✦", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateFeaturedGiftSymbol, action: {})
        case let .featuredGiftNumber(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Number", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "1337", type: .number, spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateFeaturedGiftNumber, action: {})
        case let .featuredGiftBackground(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Background", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "Violet Aurora", type: .regular(capitalization: true, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateFeaturedGiftBackground, action: {})
        case let .featuredGiftColor(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Color", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "#8B5CF6", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateFeaturedGiftColor, action: {})
        case let .featuredGiftVisible(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Visible in local profile", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateFeaturedGiftVisible)
        case let .featuredGiftPinned(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Pinned local gift", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateFeaturedGiftPinned)
        case .clearLocalGifts:
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: "Clear local gifts", kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.clearLocalGifts)
        case .profileInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Gifts use Telegram's native catalog assets and profile components. Appearance, Stars and TON decorations are stored by Stuxnet on this device and do not change Telegram or blockchain balances."), sectionId: self.section)
        }
    }
}

private func stuxnetParseTonNano(_ value: String) -> Int64? {
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
    if normalized.isEmpty {
        return 0
    }
    let components = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
    guard components.count <= 2 else {
        return nil
    }
    let wholeText = String(components[0])
    guard !wholeText.isEmpty, wholeText.allSatisfy({ $0.isNumber }), let whole = Int64(wholeText), whole <= Int64.max / 1_000_000_000 else {
        return nil
    }
    let fractionText = components.count == 2 ? String(components[1]) : ""
    guard fractionText.count <= 9, fractionText.allSatisfy({ $0.isNumber }) else {
        return nil
    }
    let paddedFraction = fractionText.padding(toLength: 9, withPad: "0", startingAt: 0)
    guard let fraction = Int64(paddedFraction) else {
        return nil
    }
    return whole * 1_000_000_000 + fraction
}

private func stuxnetSettingsEntries(settings: StuxnetSettings) -> [StuxnetSettingsEntry] {
    let ghostStatus: String
    if settings.isGhostModeEnabled {
        ghostStatus = "Active"
    } else if settings.ghostProtectionCount == 0 {
        ghostStatus = "Off"
    } else {
        ghostStatus = "Custom \(settings.ghostProtectionCount)/6"
    }
    let entries: [StuxnetSettingsEntry] = [
        .ghostHeader,
        .ghostControls(ghostStatus),
        .ghostInfo,
        .messagesHeader,
        .saveDeletedMessages(settings.saveDeletedMessages),
        .saveMessageHistory(settings.saveMessageHistory),
        .saveForBots(settings.saveForBots),
        .showMessageDetails(settings.showMessageDetails),
        .deletedMessageLabel(settings.deletedMessageLabel),
        .dimDeletedMessages(settings.dimDeletedMessages),
        .messagesInfo,
        .confirmationsHeader,
        .confirmMessageSending(settings.confirmMessageSending),
        .confirmMediaSending(settings.confirmMediaSending),
        .confirmChannelSubscriptions(settings.confirmChannelSubscriptions),
        .confirmCalls(settings.confirmCalls),
        .confirmStoryReplies(settings.confirmStoryReplies),
        .confirmStoryReactions(settings.confirmStoryReactions),
        .voiceLabHeader,
        .voiceLabEnabled(settings.voiceLabEnabled),
        .voiceLabPreset(settings.voiceLabPreset),
        .voiceLabPitchSemitones("\(settings.voiceLabPitchSemitones)"),
        .voiceLabTone("\(settings.voiceLabTone)"),
        .voiceLabRobotMix("\(settings.voiceLabRobotMix)"),
        .voiceLabGainDb("\(settings.voiceLabGainDb)"),
        .voiceLabApplyToVoiceMessages(settings.voiceLabApplyToVoiceMessages),
        .voiceLabApplyToRoundVideos(settings.voiceLabApplyToRoundVideos),
        .voiceLabApplyToCalls(settings.voiceLabApplyToCalls),
        .recordRoundVideosWithRearCamera(settings.recordRoundVideosWithRearCamera),
        .voiceLabInfo,
        .appearanceHeader,
        .chatsAppearance,
        .appearanceInfo,
        .profileHeader,
        .localProfileEffects(settings.localProfileEffects),
        .hidePhoneNumberLocally(settings.hidePhoneNumberLocally),
        .localStarsBalance("\(settings.localStarsBalance)"),
        .localTonBalance(String(format: "%.9f", Double(settings.localTonBalanceNano) / 1_000_000_000.0).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression).replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)),
        .manageGifts(settings.localGifts.count),
        .profileInfo
    ]
    return entries
}

public func stuxnetSettingsController(context: AccountContext) -> ViewController {
    var pushControllerImpl: ((ViewController) -> Void)?
    var presentControllerImpl: ((ViewController) -> Void)?
    func update(_ f: @escaping (inout StuxnetSettings) -> Void) {
        let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { current in
            var updated = current
            f(&updated)
            return updated
        }).startStandalone()
    }

    func updateFeaturedGift(_ f: @escaping (inout StuxnetLocalGift) -> Void) {
        update { settings in
            guard let index = settings.localGifts.firstIndex(where: { $0.pinned }) ?? settings.localGifts.indices.first else {
                return
            }
            f(&settings.localGifts[index])
        }
    }

    let arguments = StuxnetSettingsControllerArguments(
        updateGhostMode: { value in
            let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { $0.withUpdatedGhostMode(value) }).startStandalone()
        },
        openGhostMode: {
            pushControllerImpl?(stuxnetGhostModeController(context: context))
        },
        updateSendReadMessages: { value in update { $0.sendReadMessages = value } },
        updateSendReadStories: { value in update { $0.sendReadStories = value } },
        updateSendOnlinePresence: { value in update { $0.sendOnlinePresence = value } },
        updateSendUploadProgress: { value in update { $0.sendUploadProgress = value } },
        updateSendOfflineAfterOnline: { value in update { $0.sendOfflineAfterOnline = value } },
        updateMarkReadAfterAction: { value in update { $0.markReadAfterAction = value } },
        updateUseScheduledMessagesInGhostMode: { value in update { $0.useScheduledMessagesInGhostMode = value } },
        updateGhostSendDelaySeconds: { value in
            if let seconds = Int32(value), (10 ... 60).contains(seconds) {
                update { $0.ghostSendDelaySeconds = seconds }
            }
        },
        updateSaveDeletedMessages: { value in update { $0.saveDeletedMessages = value } },
        updateSaveMessageHistory: { value in update { $0.saveMessageHistory = value } },
        updateSaveForBots: { value in update { $0.saveForBots = value } },
        updateShowMessageDetails: { value in update { $0.showMessageDetails = value } },
        updateConfirmMessageSending: { value in update { $0.confirmMessageSending = value } },
        updateConfirmMediaSending: { value in update { $0.confirmMediaSending = value } },
        updateConfirmChannelSubscriptions: { value in update { $0.confirmChannelSubscriptions = value } },
        updateConfirmCalls: { value in update { $0.confirmCalls = value } },
        updateConfirmStoryReplies: { value in update { $0.confirmStoryReplies = value } },
        updateConfirmStoryReactions: { value in update { $0.confirmStoryReactions = value } },
        updateRecordRoundVideosWithRearCamera: { value in update { $0.recordRoundVideosWithRearCamera = value } },
        updateVoiceLabEnabled: { value in update { $0.voiceLabEnabled = value } },
        cycleVoiceLabPreset: {
            let presets: [(String, Int32, Int32, Int32, Int32)] = [
                ("Natural", 0, 0, 0, 0),
                ("Deep", -4, -30, 0, 1),
                ("Titan", -8, -52, 8, -1),
                ("Bright", 3, 35, 0, 0),
                ("Helium", 7, 48, 0, -2),
                ("Whisper", 1, -18, 12, 3),
                ("Robot", 0, -5, 70, 0),
                ("Synth", -2, 22, 52, -2),
                ("Radio", 1, 60, 18, -1),
                ("Anonymous Deep", -7, -42, 24, -2),
                ("Anonymous Flux", 5, 18, 38, -3)
            ]
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            let actionSheet = ActionSheetController(presentationData: presentationData)
            var presetItems: [ActionSheetItem] = [ActionSheetTextItem(title: "Choose a voice preset. Fine controls below can be adjusted afterwards.")]
            for (preset, pitch, tone, robotMix, gain) in presets {
                presetItems.append(ActionSheetButtonItem(title: preset, color: .accent, action: { [weak actionSheet] in
                    actionSheet?.dismissAnimated()
                    update { settings in
                        settings.voiceLabPreset = preset
                        settings.voiceLabPitchSemitones = pitch
                        settings.voiceLabTone = tone
                        settings.voiceLabRobotMix = robotMix
                        settings.voiceLabGainDb = gain
                    }
                }))
            }
            actionSheet.setItemGroups([
                ActionSheetItemGroup(items: presetItems),
                ActionSheetItemGroup(items: [ActionSheetButtonItem(title: presentationData.strings.Common_Cancel, color: .accent, font: .bold, action: { [weak actionSheet] in
                    actionSheet?.dismissAnimated()
                })])
            ])
            presentControllerImpl?(actionSheet)
        },
        updateVoiceLabPitchSemitones: { value in
            if let parsed = Int32(value), (-12 ... 12).contains(parsed) {
                update { $0.voiceLabPitchSemitones = parsed; $0.voiceLabPreset = "Custom" }
            }
        },
        updateVoiceLabTone: { value in
            if let parsed = Int32(value), (-100 ... 100).contains(parsed) {
                update { $0.voiceLabTone = parsed; $0.voiceLabPreset = "Custom" }
            }
        },
        updateVoiceLabRobotMix: { value in
            if let parsed = Int32(value), (0 ... 100).contains(parsed) {
                update { $0.voiceLabRobotMix = parsed; $0.voiceLabPreset = "Custom" }
            }
        },
        updateVoiceLabGainDb: { value in
            if let parsed = Int32(value), (-12 ... 12).contains(parsed) {
                update { $0.voiceLabGainDb = parsed; $0.voiceLabPreset = "Custom" }
            }
        },
        updateVoiceLabApplyToVoiceMessages: { value in update { $0.voiceLabApplyToVoiceMessages = value } },
        updateVoiceLabApplyToRoundVideos: { value in update { $0.voiceLabApplyToRoundVideos = value } },
        updateVoiceLabApplyToCalls: { value in update { $0.voiceLabApplyToCalls = value } },
        updateDeletedMessageLabel: { value in
            update { $0.deletedMessageLabel = String(value.prefix(24)) }
        },
        updateDimDeletedMessages: { value in update { $0.dimDeletedMessages = value } },
        updateLocalProfileEffects: { value in update { $0.localProfileEffects = value } },
        updateHidePhoneNumberLocally: { value in update { $0.hidePhoneNumberLocally = value } },
        updateCompactChatList: { value in update { $0.compactChatList = value } },
        updateShowMessageSeconds: { value in update { $0.showMessageSeconds = value } },
        updateShowMessageDate: { value in update { $0.showMessageDate = value } },
        updateShowChatListSeconds: { value in update { $0.showChatListSeconds = value } },
        updateShowChatListDate: { value in update { $0.showChatListDate = value } },
        updateUseEnglishMonthNames: { value in update { $0.useEnglishMonthNames = value } },
        openChatsAppearance: {
            pushControllerImpl?(stuxnetChatsController(context: context))
        },
        updateLocalStarsBalance: { value in
            if let amount = Int64(value), amount >= 0 {
                update { $0.localStarsBalance = amount }
            }
        },
        updateLocalTonBalance: { value in
            if let amount = stuxnetParseTonNano(value) {
                update { $0.localTonBalanceNano = amount }
            }
        },
        openGifts: {
            pushControllerImpl?(stuxnetLocalGiftsController(context: context))
        },
        installDemoGifts: {
            update {
                $0.localGifts = StuxnetLocalGift.demoGifts
                $0.localProfileEffects = true
            }
        },
        updateFeaturedGiftTitle: { value in updateFeaturedGift { $0.title = String(value.prefix(40)) } },
        updateFeaturedGiftModel: { value in updateFeaturedGift { $0.model = String(value.prefix(24)) } },
        updateFeaturedGiftSymbol: { value in updateFeaturedGift { $0.symbol = String(value.prefix(4)) } },
        updateFeaturedGiftNumber: { value in
            if value.isEmpty {
                updateFeaturedGift { $0.number = nil }
            } else if let number = Int32(value), number >= 0 {
                updateFeaturedGift { $0.number = number }
            }
        },
        updateFeaturedGiftBackground: { value in updateFeaturedGift { $0.background = String(value.prefix(32)) } },
        updateFeaturedGiftColor: { value in
            let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
            if normalized.count == 6, let color = UInt32(normalized, radix: 16) {
                updateFeaturedGift { $0.color = color }
            }
        },
        updateFeaturedGiftVisible: { value in updateFeaturedGift { $0.visible = value } },
        updateFeaturedGiftPinned: { value in updateFeaturedGift { $0.pinned = value } },
        clearLocalGifts: {
            update { $0.localGifts = [] }
        }
    )

    let signal = combineLatest(
        context.sharedContext.presentationData,
        stuxnetSettings(postbox: context.account.postbox)
    )
    |> deliverOnMainQueue
    |> map { presentationData, settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var presentationData = presentationData
        presentationData = presentationData.withUpdated(theme: presentationData.theme.withModalBlocksBackground())
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Stuxnet"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: stuxnetSettingsEntries(settings: settings),
            style: .blocks,
            animateChanges: false
        )
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    pushControllerImpl = { [weak controller] value in
        controller?.push(value)
    }
    presentControllerImpl = { [weak controller] value in
        controller?.present(value, in: .window(.root))
    }
    return controller
}
