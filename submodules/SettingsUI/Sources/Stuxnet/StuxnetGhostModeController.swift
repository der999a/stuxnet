import Foundation
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import AccountContext

private final class StuxnetGhostModeControllerArguments {
    let updateGhostMode: (Bool) -> Void
    let updateHideMessageReads: (Bool) -> Void
    let updateHideStoryViews: (Bool) -> Void
    let updateStayOffline: (Bool) -> Void
    let updateHideUploadProgress: (Bool) -> Void
    let updateSendOfflineAfterOnline: (Bool) -> Void
    let updateHideTypingActivity: (Bool) -> Void
    let updateMarkReadAfterAction: (Bool) -> Void
    let updateUseScheduledMessages: (Bool) -> Void
    let selectSendDelay: () -> Void
    let selectSendWithoutSoundMode: () -> Void

    init(
        updateGhostMode: @escaping (Bool) -> Void,
        updateHideMessageReads: @escaping (Bool) -> Void,
        updateHideStoryViews: @escaping (Bool) -> Void,
        updateStayOffline: @escaping (Bool) -> Void,
        updateHideUploadProgress: @escaping (Bool) -> Void,
        updateSendOfflineAfterOnline: @escaping (Bool) -> Void,
        updateHideTypingActivity: @escaping (Bool) -> Void,
        updateMarkReadAfterAction: @escaping (Bool) -> Void,
        updateUseScheduledMessages: @escaping (Bool) -> Void,
        selectSendDelay: @escaping () -> Void,
        selectSendWithoutSoundMode: @escaping () -> Void
    ) {
        self.updateGhostMode = updateGhostMode
        self.updateHideMessageReads = updateHideMessageReads
        self.updateHideStoryViews = updateHideStoryViews
        self.updateStayOffline = updateStayOffline
        self.updateHideUploadProgress = updateHideUploadProgress
        self.updateSendOfflineAfterOnline = updateSendOfflineAfterOnline
        self.updateHideTypingActivity = updateHideTypingActivity
        self.updateMarkReadAfterAction = updateMarkReadAfterAction
        self.updateUseScheduledMessages = updateUseScheduledMessages
        self.selectSendDelay = selectSendDelay
        self.selectSendWithoutSoundMode = selectSendWithoutSoundMode
    }
}

private enum StuxnetGhostModeSection: Int32 {
    case status
    case privacy
    case interactions
    case queue
}

private enum StuxnetGhostModeEntry: ItemListNodeEntry {
    case statusHeader
    case master(Bool)
    case status(String)
    case privacyHeader
    case hideMessageReads(Bool)
    case hideStoryViews(Bool)
    case stayOffline(Bool)
    case hideTypingActivity(Bool)
    case hideUploadProgress(Bool)
    case sendOfflineAfterOnline(Bool)
    case privacyInfo
    case interactionsHeader
    case markReadAfterAction(Bool)
    case interactionsInfo
    case queueHeader
    case useScheduledMessages(Bool)
    case sendDelay(Int32)
    case sendWithoutSound(String)
    case queueInfo

    var section: ItemListSectionId {
        switch self {
        case .statusHeader, .master, .status:
            return StuxnetGhostModeSection.status.rawValue
        case .privacyHeader, .hideMessageReads, .hideStoryViews, .stayOffline, .hideTypingActivity, .hideUploadProgress, .sendOfflineAfterOnline, .privacyInfo:
            return StuxnetGhostModeSection.privacy.rawValue
        case .interactionsHeader, .markReadAfterAction, .interactionsInfo:
            return StuxnetGhostModeSection.interactions.rawValue
        case .queueHeader, .useScheduledMessages, .sendDelay, .sendWithoutSound, .queueInfo:
            return StuxnetGhostModeSection.queue.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .statusHeader: return 0
        case .master: return 1
        case .status: return 2
        case .privacyHeader: return 10
        case .hideMessageReads: return 11
        case .hideStoryViews: return 12
        case .stayOffline: return 13
        case .hideTypingActivity: return 14
        case .hideUploadProgress: return 15
        case .sendOfflineAfterOnline: return 16
        case .privacyInfo: return 17
        case .interactionsHeader: return 20
        case .markReadAfterAction: return 21
        case .interactionsInfo: return 22
        case .queueHeader: return 30
        case .useScheduledMessages: return 31
        case .sendDelay: return 32
        case .sendWithoutSound: return 33
        case .queueInfo: return 34
        }
    }

    static func < (lhs: StuxnetGhostModeEntry, rhs: StuxnetGhostModeEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! StuxnetGhostModeControllerArguments
        switch self {
        case .statusHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "GHOST MODE", sectionId: self.section)
        case let .master(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Ghost Mode", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateGhostMode)
        case let .status(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case .privacyHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "PRIVACY SHIELDS", sectionId: self.section)
        case let .hideMessageReads(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide message reads", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHideMessageReads)
        case let .hideStoryViews(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide story views", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHideStoryViews)
        case let .stayOffline(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Stay offline while using Telegram", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateStayOffline)
        case let .hideTypingActivity(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide typing and recording activity", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHideTypingActivity)
        case let .hideUploadProgress(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide upload progress", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHideUploadProgress)
        case let .sendOfflineAfterOnline(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Send offline when protection starts", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateSendOfflineAfterOnline)
        case .privacyInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("These controls are stored separately for each account. Opening a chat can clear its badge on this device without sending a read receipt to Telegram."), sectionId: self.section)
        case .interactionsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "REACTIONS & POLLS", sectionId: self.section)
        case let .markReadAfterAction(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Reveal read state after interacting", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateMarkReadAfterAction)
        case .interactionsInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("When enabled, reacting to a message or voting in a poll may mark that chat as read. Enabling this disables the delayed-send queue, matching AyuGram's conflict handling."), sectionId: self.section)
        case .queueHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "OUTGOING MESSAGES", sectionId: self.section)
        case let .useScheduledMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Delayed-send queue", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateUseScheduledMessages)
        case let .sendDelay(value):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Queue delay", label: "\(value) sec", labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.selectSendDelay)
        case let .sendWithoutSound(value):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Send without sound", label: value, labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.selectSendWithoutSoundMode)
        case .queueInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("The queue uses Telegram's own Scheduled Messages with a short 10–60 second delay. Queued messages can be opened, edited or cancelled before Telegram sends them. Bots, paid messages, story replies and slow-mode chats bypass this queue."), sectionId: self.section)
        }
    }
}

private func stuxnetGhostModeStatus(_ settings: StuxnetSettings) -> String {
    if settings.isGhostModeEnabled {
        return "All 6 privacy shields are active. Read receipts, story views, online presence, typing activity and upload progress are suppressed."
    } else if settings.ghostProtectionCount == 0 {
        return "Protection is off. Enable the master switch or choose only the shields you need."
    } else {
        return "Custom protection is active: \(settings.ghostProtectionCount) of 6 shields enabled."
    }
}

private func stuxnetSendWithoutSoundTitle(_ value: Int32) -> String {
    switch value {
    case 1:
        return "In Ghost Mode"
    case 2:
        return "Always"
    default:
        return "Never"
    }
}

private func stuxnetGhostModeEntries(settings: StuxnetSettings) -> [StuxnetGhostModeEntry] {
    var entries: [StuxnetGhostModeEntry] = [
        .statusHeader,
        .master(settings.isGhostModeActive),
        .status(stuxnetGhostModeStatus(settings)),
        .privacyHeader,
        .hideMessageReads(!settings.sendReadMessages),
        .hideStoryViews(!settings.sendReadStories),
        .stayOffline(!settings.sendOnlinePresence),
        .hideTypingActivity(settings.hideTypingActivity),
        .hideUploadProgress(!settings.sendUploadProgress),
        .sendOfflineAfterOnline(settings.sendOfflineAfterOnline),
        .privacyInfo,
        .interactionsHeader,
        .markReadAfterAction(settings.markReadAfterAction),
        .interactionsInfo,
        .queueHeader,
        .useScheduledMessages(settings.useScheduledMessagesInGhostMode)
    ]
    if settings.useScheduledMessagesInGhostMode {
        entries.append(.sendDelay(settings.ghostSendDelaySeconds))
    }
    entries.append(.sendWithoutSound(stuxnetSendWithoutSoundTitle(settings.sendWithoutSoundMode)))
    entries.append(.queueInfo)
    return entries
}

public func stuxnetGhostModeController(context: AccountContext) -> ViewController {
    var presentControllerImpl: ((ViewController) -> Void)?

    func update(_ f: @escaping (inout StuxnetSettings) -> Void) {
        let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { current in
            var updated = current
            f(&updated)
            return updated
        }).startStandalone()
    }

    func presentChoices(text: String, choices: [(String, () -> Void)]) {
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let actionSheet = ActionSheetController(presentationData: presentationData)
        var items: [ActionSheetItem] = [ActionSheetTextItem(title: text)]
        for (choiceTitle, action) in choices {
            items.append(ActionSheetButtonItem(title: choiceTitle, color: .accent, action: { [weak actionSheet] in
                actionSheet?.dismissAnimated()
                action()
            }))
        }
        actionSheet.setItemGroups([
            ActionSheetItemGroup(items: items),
            ActionSheetItemGroup(items: [
                ActionSheetButtonItem(title: presentationData.strings.Common_Cancel, color: .accent, font: .bold, action: { [weak actionSheet] in
                    actionSheet?.dismissAnimated()
                })
            ])
        ])
        presentControllerImpl?(actionSheet)
    }

    let arguments = StuxnetGhostModeControllerArguments(
        updateGhostMode: { value in
            let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { $0.withUpdatedGhostMode(value) }).startStandalone()
        },
        updateHideMessageReads: { value in update { $0.sendReadMessages = !value } },
        updateHideStoryViews: { value in update { $0.sendReadStories = !value } },
        updateStayOffline: { value in update { $0.sendOnlinePresence = !value } },
        updateHideUploadProgress: { value in update { $0.sendUploadProgress = !value } },
        updateSendOfflineAfterOnline: { value in update { $0.sendOfflineAfterOnline = value } },
        updateHideTypingActivity: { value in update { $0.hideTypingActivity = value } },
        updateMarkReadAfterAction: { value in
            update {
                $0.markReadAfterAction = value
                if value {
                    $0.useScheduledMessagesInGhostMode = false
                }
            }
        },
        updateUseScheduledMessages: { value in
            update {
                $0.useScheduledMessagesInGhostMode = value
                if value {
                    $0.markReadAfterAction = false
                }
            }
        },
        selectSendDelay: {
            let choices: [(String, () -> Void)] = [10, 12, 15, 30, 60].map { seconds in
                ("\(seconds) seconds", { update { $0.ghostSendDelaySeconds = Int32(seconds) } })
            }
            presentChoices(text: "Choose how long a message remains editable before Telegram sends it.", choices: choices)
        },
        selectSendWithoutSoundMode: {
            let choices: [(String, () -> Void)] = [
                ("Never", { update { $0.sendWithoutSoundMode = 0 } }),
                ("Only in Ghost Mode", { update { $0.sendWithoutSoundMode = 1 } }),
                ("Always", { update { $0.sendWithoutSoundMode = 2 } })
            ]
            presentChoices(text: "Choose when outgoing messages should use Telegram's native silent-send flag.", choices: choices)
        }
    )

    let signal = combineLatest(
        context.sharedContext.presentationData,
        stuxnetSettings(postbox: context.account.postbox)
    )
    |> deliverOnMainQueue
    |> map { presentationData, settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let listPresentationData = presentationData.withUpdated(theme: presentationData.theme.withModalBlocksBackground())
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(listPresentationData),
            title: .text("Ghost Mode"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(listPresentationData),
            entries: stuxnetGhostModeEntries(settings: settings),
            style: .blocks,
            animateChanges: false
        )
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] value in
        controller?.present(value, in: .window(.root))
    }
    return controller
}
