import Foundation
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import AccountContext

private final class StuxnetChatsControllerArguments {
    let context: AccountContext
    let presentationData: Atomic<PresentationData>
    let updateCustomBubbleRadiusEnabled: (Bool) -> Void
    let updateBubbleRadius: (Int) -> Void
    let updateRemoveMessageTails: (Bool) -> Void
    let updateHideFastShareButton: (Bool) -> Void
    let updateDimDeletedMessages: (Bool) -> Void
    let updateCompactChatList: (Bool) -> Void
    let updateHideChatListAvatars: (Bool) -> Void
    let updateShowMessageSeconds: (Bool) -> Void
    let updateShowMessageDate: (Bool) -> Void
    let updateShowChatListSeconds: (Bool) -> Void
    let updateShowChatListDate: (Bool) -> Void
    let updateUseEnglishMonthNames: (Bool) -> Void
    let updateHideTypingActivity: (Bool) -> Void

    init(
        context: AccountContext,
        presentationData: Atomic<PresentationData>,
        updateCustomBubbleRadiusEnabled: @escaping (Bool) -> Void,
        updateBubbleRadius: @escaping (Int) -> Void,
        updateRemoveMessageTails: @escaping (Bool) -> Void,
        updateHideFastShareButton: @escaping (Bool) -> Void,
        updateDimDeletedMessages: @escaping (Bool) -> Void,
        updateCompactChatList: @escaping (Bool) -> Void,
        updateHideChatListAvatars: @escaping (Bool) -> Void,
        updateShowMessageSeconds: @escaping (Bool) -> Void,
        updateShowMessageDate: @escaping (Bool) -> Void,
        updateShowChatListSeconds: @escaping (Bool) -> Void,
        updateShowChatListDate: @escaping (Bool) -> Void,
        updateUseEnglishMonthNames: @escaping (Bool) -> Void,
        updateHideTypingActivity: @escaping (Bool) -> Void
    ) {
        self.context = context
        self.presentationData = presentationData
        self.updateCustomBubbleRadiusEnabled = updateCustomBubbleRadiusEnabled
        self.updateBubbleRadius = updateBubbleRadius
        self.updateRemoveMessageTails = updateRemoveMessageTails
        self.updateHideFastShareButton = updateHideFastShareButton
        self.updateDimDeletedMessages = updateDimDeletedMessages
        self.updateCompactChatList = updateCompactChatList
        self.updateHideChatListAvatars = updateHideChatListAvatars
        self.updateShowMessageSeconds = updateShowMessageSeconds
        self.updateShowMessageDate = updateShowMessageDate
        self.updateShowChatListSeconds = updateShowChatListSeconds
        self.updateShowChatListDate = updateShowChatListDate
        self.updateUseEnglishMonthNames = updateUseEnglishMonthNames
        self.updateHideTypingActivity = updateHideTypingActivity
    }
}

private enum StuxnetChatsSection: Int32 {
    case preview
    case bubbles
    case chatList
    case timestamps
    case privacy
}

private enum StuxnetChatsEntry: ItemListNodeEntry {
    case previewHeader
    case preview(Int32?, Bool)
    case bubblesHeader
    case customBubbleRadius(Bool)
    case bubbleRadius(Int32, Bool)
    case removeMessageTails(Bool)
    case hideFastShareButton(Bool)
    case dimDeletedMessages(Bool)
    case bubbleInfo
    case chatListHeader
    case compactChatList(Bool)
    case hideChatListAvatars(Bool)
    case chatListInfo
    case timestampsHeader
    case showMessageSeconds(Bool)
    case showMessageDate(Bool)
    case showChatListSeconds(Bool)
    case showChatListDate(Bool)
    case useEnglishMonthNames(Bool)
    case timestampsInfo
    case privacyHeader
    case hideTypingActivity(Bool)
    case protectedChats(Int)
    case privacyInfo

    var section: ItemListSectionId {
        switch self {
        case .previewHeader, .preview:
            return StuxnetChatsSection.preview.rawValue
        case .bubblesHeader, .customBubbleRadius, .bubbleRadius, .removeMessageTails, .hideFastShareButton, .dimDeletedMessages, .bubbleInfo:
            return StuxnetChatsSection.bubbles.rawValue
        case .chatListHeader, .compactChatList, .hideChatListAvatars, .chatListInfo:
            return StuxnetChatsSection.chatList.rawValue
        case .timestampsHeader, .showMessageSeconds, .showMessageDate, .showChatListSeconds, .showChatListDate, .useEnglishMonthNames, .timestampsInfo:
            return StuxnetChatsSection.timestamps.rawValue
        case .privacyHeader, .hideTypingActivity, .protectedChats, .privacyInfo:
            return StuxnetChatsSection.privacy.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .previewHeader: return 0
        case .preview: return 1
        case .bubblesHeader: return 10
        case .customBubbleRadius: return 11
        case .bubbleRadius: return 12
        case .removeMessageTails: return 13
        case .hideFastShareButton: return 14
        case .dimDeletedMessages: return 15
        case .bubbleInfo: return 16
        case .chatListHeader: return 20
        case .compactChatList: return 21
        case .hideChatListAvatars: return 22
        case .chatListInfo: return 23
        case .timestampsHeader: return 30
        case .showMessageSeconds: return 31
        case .showMessageDate: return 32
        case .showChatListSeconds: return 33
        case .showChatListDate: return 34
        case .useEnglishMonthNames: return 35
        case .timestampsInfo: return 36
        case .privacyHeader: return 40
        case .hideTypingActivity: return 41
        case .protectedChats: return 42
        case .privacyInfo: return 43
        }
    }

    static func < (lhs: StuxnetChatsEntry, rhs: StuxnetChatsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! StuxnetChatsControllerArguments
        switch self {
        case .previewHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "LIVE PREVIEW", sectionId: self.section)
        case let .preview(radius, removeTails):
            let current = arguments.presentationData.with { $0 }
            let fallback = current.chatBubbleCorners
            let mainRadius = CGFloat(radius ?? Int32(fallback.mainRadius))
            let corners = PresentationChatBubbleCorners(
                mainRadius: max(8.0, min(16.0, mainRadius)),
                auxiliaryRadius: radius == nil ? fallback.auxiliaryRadius : min(fallback.auxiliaryRadius, max(4.0, mainRadius * 0.5)),
                mergeBubbleCorners: fallback.mergeBubbleCorners,
                hasTails: !removeTails
            )
            return ThemeSettingsChatPreviewItem(
                context: arguments.context,
                systemStyle: .glass,
                theme: current.theme.withModalBlocksBackground(),
                componentTheme: current.theme,
                strings: current.strings,
                sectionId: self.section,
                fontSize: current.chatFontSize,
                chatBubbleCorners: corners,
                wallpaper: current.chatWallpaper,
                dateTimeFormat: current.dateTimeFormat,
                nameDisplayOrder: current.nameDisplayOrder,
                messageItems: [
                    ChatPreviewMessageItem(outgoing: false, reply: ("gamesense when?", "ask latviankult"), text: "ask latviankult", nameColor: .preset(.blue), backgroundEmojiId: nil)
                ]
            )
        case .bubblesHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "MESSAGES", sectionId: self.section)
        case let .customBubbleRadius(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Custom bubble radius", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateCustomBubbleRadiusEnabled)
        case let .bubbleRadius(value, enabled):
            return BubbleSettingsRadiusItem(theme: presentationData.theme, value: Int(value), enabled: enabled, disableLeadingInset: false, displayIcons: false, disableDecorations: true, force: false, sectionId: self.section, updated: arguments.updateBubbleRadius)
        case let .removeMessageTails(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Remove message tails", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateRemoveMessageTails)
        case let .hideFastShareButton(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide side Share button", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHideFastShareButton)
        case let .dimDeletedMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Translucent deleted messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateDimDeletedMessages)
        case .bubbleInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("The preview uses Telegram's real message renderer and current wallpaper. Radius and tails update open chats; ads keep their required action button."), sectionId: self.section)
        case .chatListHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "CHAT LIST", sectionId: self.section)
        case let .compactChatList(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Compact rows", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateCompactChatList)
        case let .hideChatListAvatars(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide chat avatars", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHideChatListAvatars)
        case .chatListInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Hidden avatars reclaim the leading space for titles and message previews. Topic, community and inline layouts keep their structural icons."), sectionId: self.section)
        case .timestampsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "TIMESTAMPS", sectionId: self.section)
        case let .showMessageSeconds(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Seconds in messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowMessageSeconds)
        case let .showMessageDate(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Date in messages", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowMessageDate)
        case let .showChatListSeconds(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Seconds in chat list", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowChatListSeconds)
        case let .showChatListDate(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Date in chat list", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateShowChatListDate)
        case let .useEnglishMonthNames(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "English short months", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateUseEnglishMonthNames)
        case .timestampsInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Examples: 9 авг 19:30:23 or 9 Aug 19:30:23. Message and chat-list formats are independent."), sectionId: self.section)
        case .privacyHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ACTIVITY", sectionId: self.section)
        case let .hideTypingActivity(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide typing and recording activity", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateHideTypingActivity)
        case let .protectedChats(count):
            return ItemListTextItem(presentationData: presentationData, text: .plain("Long-press a chat and choose Lock with Face ID or Touch ID. Rows, search previews and notifications stay covered. Protected chats: \(count)."), sectionId: self.section)
        case .privacyInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Suppresses typing, voice/video recording, sticker selection and emoji interaction actions. Upload progress and group-call speaking remain controlled separately."), sectionId: self.section)
        }
    }
}

private func stuxnetChatsEntries(settings: StuxnetSettings, presentationData: PresentationData) -> [StuxnetChatsEntry] {
    let effectiveRadius = settings.customMessageBubbleRadius ?? Int32(presentationData.chatBubbleCorners.mainRadius)
    return [
        .previewHeader,
        .preview(settings.customMessageBubbleRadius, settings.removeMessageTails),
        .bubblesHeader,
        .customBubbleRadius(settings.customMessageBubbleRadius != nil),
        .bubbleRadius(max(8, min(16, effectiveRadius)), settings.customMessageBubbleRadius != nil),
        .removeMessageTails(settings.removeMessageTails),
        .hideFastShareButton(settings.hideFastShareButton),
        .dimDeletedMessages(settings.dimDeletedMessages),
        .bubbleInfo,
        .chatListHeader,
        .compactChatList(settings.compactChatList),
        .hideChatListAvatars(settings.hideChatListAvatars),
        .chatListInfo,
        .timestampsHeader,
        .showMessageSeconds(settings.showMessageSeconds),
        .showMessageDate(settings.showMessageDate),
        .showChatListSeconds(settings.showChatListSeconds),
        .showChatListDate(settings.showChatListDate),
        .useEnglishMonthNames(settings.useEnglishMonthNames),
        .timestampsInfo,
        .privacyHeader,
        .hideTypingActivity(settings.hideTypingActivity),
        .protectedChats(settings.lockedPeerIds.count),
        .privacyInfo
    ]
}

public func stuxnetChatsController(context: AccountContext) -> ViewController {
    let currentPresentationData = Atomic(value: context.sharedContext.currentPresentationData.with { $0 })

    func update(_ f: @escaping (inout StuxnetSettings) -> Void) {
        let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { current in
            var updated = current
            f(&updated)
            return updated
        }).startStandalone()
    }

    let arguments = StuxnetChatsControllerArguments(
        context: context,
        presentationData: currentPresentationData,
        updateCustomBubbleRadiusEnabled: { value in
            update {
                if value {
                    let radius = context.sharedContext.currentPresentationData.with { Int32($0.chatBubbleCorners.mainRadius) }
                    $0.customMessageBubbleRadius = max(8, min(16, radius))
                } else {
                    $0.customMessageBubbleRadius = nil
                }
            }
        },
        updateBubbleRadius: { value in
            update { $0.customMessageBubbleRadius = Int32(max(8, min(16, value))) }
        },
        updateRemoveMessageTails: { value in update { $0.removeMessageTails = value } },
        updateHideFastShareButton: { value in update { $0.hideFastShareButton = value } },
        updateDimDeletedMessages: { value in update { $0.dimDeletedMessages = value } },
        updateCompactChatList: { value in update { $0.compactChatList = value } },
        updateHideChatListAvatars: { value in update { $0.hideChatListAvatars = value } },
        updateShowMessageSeconds: { value in update { $0.showMessageSeconds = value } },
        updateShowMessageDate: { value in update { $0.showMessageDate = value } },
        updateShowChatListSeconds: { value in update { $0.showChatListSeconds = value } },
        updateShowChatListDate: { value in update { $0.showChatListDate = value } },
        updateUseEnglishMonthNames: { value in update { $0.useEnglishMonthNames = value } },
        updateHideTypingActivity: { value in update { $0.hideTypingActivity = value } }
    )

    let signal = combineLatest(
        context.sharedContext.presentationData,
        stuxnetSettings(postbox: context.account.postbox)
    )
    |> deliverOnMainQueue
    |> map { presentationData, settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let _ = currentPresentationData.swap(presentationData)
        let listPresentationData = presentationData.withUpdated(theme: presentationData.theme.withModalBlocksBackground())
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(listPresentationData),
            title: .text("Chats & Appearance"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(listPresentationData),
            entries: stuxnetChatsEntries(settings: settings, presentationData: presentationData),
            style: .blocks,
            animateChanges: false
        )
        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
