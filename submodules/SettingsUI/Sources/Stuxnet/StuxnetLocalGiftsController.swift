import Foundation
import UIKit
import Display
import Postbox
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import AccountContext
import GiftViewScreen
import AlertUI
import PresentationDataUtils

private struct StuxnetLocalGiftsState: Equatable {
    var query: String = ""
    var slug: String = ""
    var giftId: String = ""
    var status: String?
    var isLoading: Bool = false
}

private final class StuxnetLocalGiftsArguments {
    let updateQuery: (String) -> Void
    let updateSlug: (String) -> Void
    let updateGiftId: (String) -> Void
    let importSlug: () -> Void
    let importGiftId: () -> Void
    let refresh: () -> Void
    let openLocalGift: (String) -> Void
    let openCatalogGift: (StarGift) -> Void

    init(
        updateQuery: @escaping (String) -> Void,
        updateSlug: @escaping (String) -> Void,
        updateGiftId: @escaping (String) -> Void,
        importSlug: @escaping () -> Void,
        importGiftId: @escaping () -> Void,
        refresh: @escaping () -> Void,
        openLocalGift: @escaping (String) -> Void,
        openCatalogGift: @escaping (StarGift) -> Void
    ) {
        self.updateQuery = updateQuery
        self.updateSlug = updateSlug
        self.updateGiftId = updateGiftId
        self.importSlug = importSlug
        self.importGiftId = importGiftId
        self.refresh = refresh
        self.openLocalGift = openLocalGift
        self.openCatalogGift = openCatalogGift
    }
}

private enum StuxnetLocalGiftsSection: Int32 {
    case search
    case importGift
    case collection
    case catalog
}

private enum StuxnetLocalGiftsEntry: ItemListNodeEntry {
    case search(String)
    case importHeader
    case slugInput(String)
    case importSlug(Bool)
    case giftIdInput(String)
    case importGiftId(Bool)
    case refresh(Bool)
    case status(String)
    case importInfo
    case collectionHeader(Int, Int)
    case emptyCollection(String)
    case localGift(Int32, StuxnetLocalGift)
    case collectionLegend
    case catalogHeader(Int, Int)
    case emptyCatalog(String)
    case catalogGift(Int32, StarGift)
    case catalogInfo

    var section: ItemListSectionId {
        switch self {
        case .search:
            return StuxnetLocalGiftsSection.search.rawValue
        case .importHeader, .slugInput, .importSlug, .giftIdInput, .importGiftId, .refresh, .status, .importInfo:
            return StuxnetLocalGiftsSection.importGift.rawValue
        case .collectionHeader, .emptyCollection, .localGift, .collectionLegend:
            return StuxnetLocalGiftsSection.collection.rawValue
        case .catalogHeader, .emptyCatalog, .catalogGift, .catalogInfo:
            return StuxnetLocalGiftsSection.catalog.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .search: return 0
        case .importHeader: return 10
        case .slugInput: return 11
        case .importSlug: return 12
        case .giftIdInput: return 13
        case .importGiftId: return 14
        case .refresh: return 15
        case .status: return 16
        case .importInfo: return 17
        case .collectionHeader: return 100
        case .emptyCollection: return 101
        case let .localGift(index, _): return 1000 + index
        case .collectionLegend: return 9000
        case .catalogHeader: return 10000
        case .emptyCatalog: return 10001
        case let .catalogGift(index, _): return 11000 + index
        case .catalogInfo: return 20000
        }
    }

    static func < (lhs: StuxnetLocalGiftsEntry, rhs: StuxnetLocalGiftsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! StuxnetLocalGiftsArguments
        switch self {
        case let .search(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Search", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "Title, model, slug, ID or owner", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateQuery, action: {})
        case .importHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ADD GIFT", sectionId: self.section)
        case let .slugInput(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Unique slug", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "PlushPepe-12345", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateSlug, action: {})
        case let .importSlug(isLoading):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: isLoading ? "Loading collectible…" : "Get collectible by slug", kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.importSlug)
        case let .giftIdInput(value):
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Catalog ID", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "5170145012310081615", type: .number, spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateGiftId, action: {})
        case let .importGiftId(isLoading):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: isLoading ? "Loading gift…" : "Add gift by ID", kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.importGiftId)
        case let .refresh(isLoading):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: isLoading ? "Refreshing catalog…" : "Refresh Telegram catalog", kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.refresh)
        case let .status(value):
            return ItemListTextItem(presentationData: presentationData, text: .plain(value), sectionId: self.section)
        case .importInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Paste a collectible slug or choose a regular Star Gift from Telegram's current catalog. The original animation and collectible attributes are cached for native preview."), sectionId: self.section)
        case let .collectionHeader(count, totalCount):
            let value = count == totalCount ? "\(count)" : "\(count)/\(totalCount)"
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "MY GIFTS · \(value)", sectionId: self.section)
        case let .emptyCollection(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .localGift(_, gift):
            let number = gift.number.map { " #\($0)" } ?? ""
            let title = NSMutableAttributedString(string: "\(gift.title)\(number)", attributes: [
                .font: Font.regular(17.0),
                .foregroundColor: presentationData.theme.list.itemPrimaryTextColor
            ])
            if gift.equipped {
                title.append(NSAttributedString(string: "  ◆", attributes: [.font: Font.semibold(12.0), .foregroundColor: UIColor(rgb: 0x34c759)]))
            }
            if gift.pinned {
                title.append(NSAttributedString(string: "  ●", attributes: [.font: Font.semibold(12.0), .foregroundColor: UIColor(rgb: 0xffb000)]))
            }
            if !gift.visible {
                title.append(NSAttributedString(string: "  ◌", attributes: [.font: Font.semibold(13.0), .foregroundColor: presentationData.theme.list.itemSecondaryTextColor]))
            }
            var details = [gift.model, gift.background]
            if gift.localOwner != "Me" {
                details.append("→ \(gift.localOwner)")
            }
            let color = UIColor(rgb: gift.color).withAlphaComponent(gift.visible ? 1.0 : 0.45)
            let icon = generateFilledCircleImage(diameter: 28.0, color: color, strokeColor: presentationData.theme.list.itemBlocksSeparatorColor, strokeWidth: 1.0)
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: icon, title: title.string, attributedTitle: title, label: details.joined(separator: " · "), labelStyle: .multilineDetailText, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openLocalGift(gift.id)
            })
        case .collectionLegend:
            return ItemListTextItem(presentationData: presentationData, text: .plain("◆ Worn   ● Pinned   ◌ Hidden"), sectionId: self.section)
        case let .catalogHeader(count, totalCount):
            let value = count == totalCount ? "\(count)" : "\(count)/\(totalCount)"
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "TELEGRAM CATALOG · \(value)", sectionId: self.section)
        case let .emptyCatalog(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .catalogGift(_, gift):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: stuxnetGiftTitle(gift), label: stuxnetGiftDetail(gift), labelStyle: .multilineDetailText, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openCatalogGift(gift)
            })
        case .catalogInfo:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Opening a catalog item uses Telegram's own animated gift preview. Adding, hiding, wearing and moving it between local owners changes only the Stuxnet collection on this device."), sectionId: self.section)
        }
    }
}

private func stuxnetGiftTitle(_ gift: StarGift) -> String {
    switch gift {
    case let .generic(value):
        return value.title ?? "Star Gift"
    case let .unique(value):
        return "\(value.title) #\(value.number)"
    }
}

private func stuxnetGiftDetail(_ gift: StarGift) -> String {
    switch gift {
    case let .generic(value):
        var components = ["ID \(value.id)", "⭐️ \(value.price)"]
        if let availability = value.availability {
            components.append("\(availability.remains)/\(availability.total) left")
        }
        return components.joined(separator: " · ")
    case let .unique(value):
        var model = "Collectible"
        var backdrop = ""
        for attribute in value.attributes {
            switch attribute {
            case let .model(name, _, _, _): model = name
            case let .backdrop(name, _, _, _, _, _, _): backdrop = name
            default: break
            }
        }
        return [value.slug, model, backdrop].filter { !$0.isEmpty }.joined(separator: " · ")
    }
}

private func stuxnetSearchValue(_ value: String) -> String {
    return value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
}

private func stuxnetLocalGiftMatchesQuery(_ gift: StuxnetLocalGift, query: String) -> Bool {
    let query = stuxnetSearchValue(query.trimmingCharacters(in: .whitespacesAndNewlines))
    guard !query.isEmpty else {
        return true
    }
    var values = [
        gift.id,
        gift.title,
        gift.model,
        gift.symbol,
        gift.background,
        gift.localOwner,
        stuxnetGiftColorString(gift.color)
    ]
    if let number = gift.number {
        values.append("\(number)")
    }
    if let catalogGiftId = gift.catalogGiftId {
        values.append("\(catalogGiftId)")
    }
    if let uniqueSlug = gift.uniqueSlug {
        values.append(uniqueSlug)
    }
    return stuxnetSearchValue(values.joined(separator: " ")).contains(query)
}

private func stuxnetCatalogGiftMatchesQuery(_ gift: StarGift, query: String) -> Bool {
    let query = stuxnetSearchValue(query.trimmingCharacters(in: .whitespacesAndNewlines))
    guard !query.isEmpty else {
        return true
    }
    var values = [stuxnetGiftTitle(gift), stuxnetGiftDetail(gift)]
    switch gift {
    case let .generic(value):
        values.append("\(value.id)")
        values.append("\(value.price)")
    case let .unique(value):
        values.append("\(value.id)")
        values.append("\(value.giftId)")
        values.append("\(value.number)")
        values.append(value.slug)
        for attribute in value.attributes {
            switch attribute {
            case let .model(name, _, _, _), let .pattern(name, _, _), let .backdrop(name, _, _, _, _, _, _):
                values.append(name)
            case .originalInfo:
                break
            }
        }
    }
    return stuxnetSearchValue(values.joined(separator: " ")).contains(query)
}

private func stuxnetGiftColorString(_ color: UInt32) -> String {
    return String(format: "#%06X", color & 0x00ffffff)
}

private func stuxnetParseGiftColor(_ value: String) -> UInt32? {
    var value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if value.hasPrefix("#") {
        value.removeFirst()
    }
    guard value.count == 6, let color = UInt32(value, radix: 16) else {
        return nil
    }
    return color
}

private func stuxnetNormalizedGiftSlug(_ value: String) -> String {
    var result = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if let url = URL(string: result), let host = url.host, !host.isEmpty {
        result = url.lastPathComponent
    }
    if let queryIndex = result.firstIndex(of: "?") {
        result = String(result[..<queryIndex])
    }
    return result.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
}

private func stuxnetStoreGift(context: AccountContext, gift: StarGift) {
    let imported = StuxnetLocalGift.imported(gift: gift)
    let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { current in
        var updated = current
        if let index = updated.localGifts.firstIndex(where: { $0.id == imported.id }) {
            var replacement = imported
            replacement.visible = updated.localGifts[index].visible
            replacement.pinned = updated.localGifts[index].pinned
            replacement.equipped = updated.localGifts[index].equipped
            replacement.localOwner = updated.localGifts[index].localOwner
            replacement.localOwnerPeerId = updated.localGifts[index].localOwnerPeerId
            replacement.transfers = updated.localGifts[index].transfers
            replacement.model = updated.localGifts[index].model
            replacement.symbol = updated.localGifts[index].symbol
            replacement.color = updated.localGifts[index].color
            replacement.number = updated.localGifts[index].number
            replacement.background = updated.localGifts[index].background
            replacement.previewAttributes = updated.localGifts[index].previewAttributes
            replacement.createdAt = updated.localGifts[index].createdAt
            updated.localGifts[index] = replacement
        } else {
            updated.localGifts.append(imported)
        }
        updated.localProfileEffects = true
        return updated
    }).startStandalone()
}

private func stuxnetGiftPreviewController(context: AccountContext, gift: StarGift, attributes: [StarGift.UniqueGift.Attribute]?, actionTitle: String? = nil, action: (() -> Void)? = nil) -> ViewController {
    let customAction: GiftViewScreen.CustomAction?
    if let actionTitle, let action {
        customAction = GiftViewScreen.CustomAction(title: actionTitle, action: action)
    } else {
        let doneTitle = context.sharedContext.currentPresentationData.with { $0 }.strings.Common_Done
        customAction = GiftViewScreen.CustomAction(title: doneTitle, action: {})
    }
    return GiftViewScreen(
        context: context,
        subject: .wearPreview(gift, attributes?.isEmpty == false ? attributes : nil),
        customAction: customAction
    )
}

private func stuxnetLocalGiftsEntries(state: StuxnetLocalGiftsState, settings: StuxnetSettings, catalog: [StarGift]) -> [StuxnetLocalGiftsEntry] {
    let filteredLocalGifts = settings.localGifts.filter { stuxnetLocalGiftMatchesQuery($0, query: state.query) }
    let filteredCatalog = catalog.filter { stuxnetCatalogGiftMatchesQuery($0, query: state.query) }
    let hasQuery = !state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    var entries: [StuxnetLocalGiftsEntry] = [
        .search(state.query),
        .importHeader,
        .slugInput(state.slug),
        .importSlug(state.isLoading),
        .giftIdInput(state.giftId),
        .importGiftId(state.isLoading),
        .refresh(state.isLoading)
    ]
    if let status = state.status, !status.isEmpty {
        entries.append(.status(status))
    }
    entries.append(.importInfo)
    entries.append(.collectionHeader(filteredLocalGifts.count, settings.localGifts.count))
    if filteredLocalGifts.isEmpty {
        entries.append(.emptyCollection(hasQuery && !settings.localGifts.isEmpty ? "No gifts match this search." : "No gifts yet. Add one by slug, ID or from the catalog below."))
    } else {
        for (index, gift) in filteredLocalGifts.enumerated() {
            entries.append(.localGift(Int32(index), gift))
        }
        entries.append(.collectionLegend)
    }
    entries.append(.catalogHeader(filteredCatalog.count, catalog.count))
    if filteredCatalog.isEmpty {
        entries.append(.emptyCatalog(hasQuery && !catalog.isEmpty ? "No catalog gifts match this search." : "Catalog is not cached yet. Tap Refresh Telegram catalog while the account is online."))
    } else {
        for (index, gift) in filteredCatalog.prefix(100).enumerated() {
            entries.append(.catalogGift(Int32(index), gift))
        }
    }
    entries.append(.catalogInfo)
    return entries
}

public func stuxnetLocalGiftsController(context: AccountContext) -> ViewController {
    let initialState = StuxnetLocalGiftsState()
    let stateValue = Atomic(value: initialState)
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let updateState: ((StuxnetLocalGiftsState) -> StuxnetLocalGiftsState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    let catalogValue = Atomic<[StarGift]>(value: [])

    var pushControllerImpl: ((ViewController) -> Void)?
    var presentControllerImpl: ((ViewController) -> Void)?

    let arguments = StuxnetLocalGiftsArguments(
        updateQuery: { value in
            updateState { current in
                var updated = current
                updated.query = String(value.prefix(96))
                return updated
            }
        },
        updateSlug: { value in
            updateState { current in
                var updated = current
                updated.slug = String(value.prefix(160))
                updated.status = nil
                return updated
            }
        },
        updateGiftId: { value in
            updateState { current in
                var updated = current
                updated.giftId = String(value.prefix(24))
                updated.status = nil
                return updated
            }
        },
        importSlug: {
            let state = stateValue.with { $0 }
            let slug = stuxnetNormalizedGiftSlug(state.slug)
            guard !slug.isEmpty, !state.isLoading else {
                return
            }
            updateState { current in
                var updated = current
                updated.isLoading = true
                updated.status = "Resolving \(slug)…"
                return updated
            }
            let _ = (context.engine.payments.getUniqueStarGift(slug: slug)
            |> deliverOnMainQueue).start(next: { gift in
                stuxnetStoreGift(context: context, gift: .unique(gift))
                updateState { current in
                    var updated = current
                    updated.isLoading = false
                    updated.slug = ""
                    updated.status = "Added \(gift.title) #\(gift.number)."
                    return updated
                }
                presentControllerImpl?(stuxnetGiftPreviewController(context: context, gift: .unique(gift), attributes: gift.attributes))
            }, error: { _ in
                updateState { current in
                    var updated = current
                    updated.isLoading = false
                    updated.status = "Collectible not found. Check the exact slug or link."
                    return updated
                }
            })
        },
        importGiftId: {
            let state = stateValue.with { $0 }
            guard !state.isLoading, let giftId = Int64(state.giftId) else {
                updateState { current in
                    var updated = current
                    updated.status = "Enter a numeric catalog gift ID."
                    return updated
                }
                return
            }
            guard let gift = catalogValue.with({ gifts in
                gifts.first(where: { item in
                    switch item {
                    case let .generic(value): return value.id == giftId
                    case let .unique(value): return value.id == giftId || value.giftId == giftId
                    }
                })
            }) else {
                updateState { current in
                    var updated = current
                    updated.status = "Gift ID \(giftId) is not in the cached catalog. Refresh it or use a unique slug."
                    return updated
                }
                return
            }
            stuxnetStoreGift(context: context, gift: gift)
            updateState { current in
                var updated = current
                updated.giftId = ""
                updated.status = "Added \(stuxnetGiftTitle(gift))."
                return updated
            }
            presentControllerImpl?(stuxnetGiftPreviewController(context: context, gift: gift, attributes: nil))
        },
        refresh: {
            updateState { current in
                var updated = current
                updated.isLoading = true
                updated.status = "Refreshing Telegram gift catalog…"
                return updated
            }
            let _ = (context.engine.payments.keepStarGiftsUpdated()
            |> deliverOnMainQueue).start(completed: {
                updateState { current in
                    var updated = current
                    updated.isLoading = false
                    updated.status = "Catalog refreshed."
                    return updated
                }
            })
        },
        openLocalGift: { id in
            pushControllerImpl?(stuxnetLocalGiftEditorController(context: context, giftId: id))
        },
        openCatalogGift: { gift in
            presentControllerImpl?(stuxnetGiftPreviewController(context: context, gift: gift, attributes: nil, actionTitle: "Add to My Gifts", action: {
                stuxnetStoreGift(context: context, gift: gift)
                updateState { current in
                    var updated = current
                    updated.status = "Added \(stuxnetGiftTitle(gift))."
                    return updated
                }
            }))
        }
    )

    let catalogSignal = context.engine.payments.cachedStarGifts()
    |> map { $0 ?? [] }
    |> distinctUntilChanged

    let signal = combineLatest(
        context.sharedContext.presentationData,
        statePromise.get(),
        stuxnetSettings(postbox: context.account.postbox),
        catalogSignal
    )
    |> deliverOnMainQueue
    |> map { presentationData, state, settings, catalog -> (ItemListControllerState, (ItemListNodeState, Any)) in
        _ = catalogValue.swap(catalog)
        var presentationData = presentationData
        presentationData = presentationData.withUpdated(theme: presentationData.theme.withModalBlocksBackground())
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Gifts"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: stuxnetLocalGiftsEntries(state: state, settings: settings, catalog: catalog),
            style: .blocks,
            animateChanges: true
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
    let _ = context.engine.payments.keepStarGiftsUpdated().startStandalone()
    return controller
}

private enum StuxnetGiftVariantKind {
    case model
    case pattern
    case backdrop
}

private struct StuxnetGiftEditorState: Equatable {
    var colorInput: String?
    var variants: [StarGift.UniqueGift.Attribute] = []
    var status: String?
}

private final class StuxnetGiftEditorArguments {
    let preview: () -> Void
    let updateVisible: (Bool) -> Void
    let updatePinned: (Bool) -> Void
    let updateEquipped: (Bool) -> Void
    let updateNumber: (String) -> Void
    let updateColor: (String) -> Void
    let selectOwner: () -> Void
    let selectModel: () -> Void
    let selectPattern: () -> Void
    let selectBackdrop: () -> Void
    let resetVariants: () -> Void
    let remove: () -> Void

    init(preview: @escaping () -> Void, updateVisible: @escaping (Bool) -> Void, updatePinned: @escaping (Bool) -> Void, updateEquipped: @escaping (Bool) -> Void, updateNumber: @escaping (String) -> Void, updateColor: @escaping (String) -> Void, selectOwner: @escaping () -> Void, selectModel: @escaping () -> Void, selectPattern: @escaping () -> Void, selectBackdrop: @escaping () -> Void, resetVariants: @escaping () -> Void, remove: @escaping () -> Void) {
        self.preview = preview
        self.updateVisible = updateVisible
        self.updatePinned = updatePinned
        self.updateEquipped = updateEquipped
        self.updateNumber = updateNumber
        self.updateColor = updateColor
        self.selectOwner = selectOwner
        self.selectModel = selectModel
        self.selectPattern = selectPattern
        self.selectBackdrop = selectBackdrop
        self.resetVariants = resetVariants
        self.remove = remove
    }
}

private enum StuxnetGiftEditorEntry: ItemListNodeEntry {
    case header(String)
    case preview
    case visible(Bool)
    case pinned(Bool)
    case equipped(Bool)
    case number(String)
    case variantsHeader
    case model(String, Bool)
    case pattern(String, Bool)
    case backdrop(String, Bool)
    case color(String, UInt32)
    case resetVariants
    case ownershipHeader
    case owner(String)
    case transferHistory(Int32, String)
    case status(String)
    case remove
    case info

    var section: ItemListSectionId {
        switch self {
        case .header, .preview, .visible, .pinned, .equipped, .number: return 0
        case .variantsHeader, .model, .pattern, .backdrop, .color, .resetVariants: return 1
        case .ownershipHeader, .owner, .transferHistory: return 2
        case .status, .remove, .info: return 3
        }
    }

    var stableId: Int32 {
        switch self {
        case .header: return 0
        case .preview: return 1
        case .visible: return 2
        case .pinned: return 3
        case .equipped: return 4
        case .number: return 5
        case .variantsHeader: return 10
        case .model: return 11
        case .pattern: return 12
        case .backdrop: return 13
        case .color: return 14
        case .resetVariants: return 15
        case .ownershipHeader: return 20
        case .owner: return 21
        case let .transferHistory(index, _): return 100 + index
        case .status: return 500
        case .remove: return 501
        case .info: return 502
        }
    }

    static func < (lhs: StuxnetGiftEditorEntry, rhs: StuxnetGiftEditorEntry) -> Bool { lhs.stableId < rhs.stableId }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! StuxnetGiftEditorArguments
        switch self {
        case let .header(value): return ItemListSectionHeaderItem(presentationData: presentationData, text: value, sectionId: self.section)
        case .preview: return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: "Open animated preview", kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.preview)
        case let .visible(value): return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Show in profile", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateVisible)
        case let .pinned(value): return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Pin as featured gift", value: value, sectionId: self.section, style: .blocks, updated: arguments.updatePinned)
        case let .equipped(value): return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Wear this gift", value: value, sectionId: self.section, style: .blocks, updated: arguments.updateEquipped)
        case let .number(value): return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: NSAttributedString(string: "Display number", textColor: presentationData.theme.list.itemPrimaryTextColor), text: value, placeholder: "Original", type: .number, spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateNumber, action: {})
        case .variantsHeader: return ItemListSectionHeaderItem(presentationData: presentationData, text: "APPEARANCE VARIANTS", sectionId: self.section)
        case let .model(value, enabled): return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Model", enabled: enabled, label: enabled ? value : "No server variants", sectionId: self.section, style: .blocks, disclosureStyle: enabled ? .arrow : .none, action: enabled ? arguments.selectModel : nil)
        case let .pattern(value, enabled): return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Symbol", enabled: enabled, label: enabled ? value : "No server variants", sectionId: self.section, style: .blocks, disclosureStyle: enabled ? .arrow : .none, action: enabled ? arguments.selectPattern : nil)
        case let .backdrop(value, enabled): return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Backdrop", enabled: enabled, label: enabled ? value : "No server variants", sectionId: self.section, style: .blocks, disclosureStyle: enabled ? .arrow : .none, action: enabled ? arguments.selectBackdrop : nil)
        case let .color(value, color):
            let title = NSMutableAttributedString(string: "●  ", attributes: [.font: Font.semibold(17.0), .foregroundColor: UIColor(rgb: color)])
            title.append(NSAttributedString(string: "Color", attributes: [.font: Font.regular(17.0), .foregroundColor: presentationData.theme.list.itemPrimaryTextColor]))
            return ItemListSingleLineInputItem(presentationData: presentationData, systemStyle: .glass, title: title, text: value, placeholder: "#8B5CF6", type: .regular(capitalization: false, autocorrection: false), spacing: 10.0, sectionId: self.section, textUpdated: arguments.updateColor, action: {})
        case .resetVariants: return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: "Reset original appearance", kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.resetVariants)
        case .ownershipHeader: return ItemListSectionHeaderItem(presentationData: presentationData, text: "OWNERSHIP", sectionId: self.section)
        case let .owner(value): return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: "Owner", label: value, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.selectOwner)
        case let .transferHistory(_, value): return ItemListTextItem(presentationData: presentationData, text: .plain(value), sectionId: self.section)
        case let .status(value): return ItemListTextItem(presentationData: presentationData, text: .plain(value), sectionId: self.section)
        case .remove: return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: "Remove gift", kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: arguments.remove)
        case .info: return ItemListTextItem(presentationData: presentationData, text: .plain("Wear, pin, visibility, appearance variants, owner and transfer history are saved in Stuxnet. Telegram purchases and blockchain ownership are not modified."), sectionId: self.section)
        }
    }
}

private func stuxnetAttributeName(_ attribute: StarGift.UniqueGift.Attribute, kind: StuxnetGiftVariantKind) -> String? {
    switch (kind, attribute) {
    case let (.model, .model(name, _, _, _)): return name
    case let (.pattern, .pattern(name, _, _)): return name
    case let (.backdrop, .backdrop(name, _, _, _, _, _, _)): return name
    default: return nil
    }
}

private func stuxnetOriginalAttributes(_ gift: StuxnetLocalGift) -> [StarGift.UniqueGift.Attribute] {
    if case let .unique(value) = gift.sourceGift {
        return value.attributes
    }
    return []
}

private final class StuxnetGiftVariantSelectionArguments {
    let select: (StarGift.UniqueGift.Attribute) -> Void

    init(select: @escaping (StarGift.UniqueGift.Attribute) -> Void) {
        self.select = select
    }
}

private struct StuxnetGiftVariantSelectionEntry: ItemListNodeEntry {
    let index: Int32
    let name: String
    let attribute: StarGift.UniqueGift.Attribute
    let selected: Bool

    var section: ItemListSectionId {
        return 0
    }

    var stableId: Int32 {
        return self.index
    }

    static func < (lhs: StuxnetGiftVariantSelectionEntry, rhs: StuxnetGiftVariantSelectionEntry) -> Bool {
        return lhs.index < rhs.index
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! StuxnetGiftVariantSelectionArguments
        return ItemListCheckboxItem(
            presentationData: presentationData,
            systemStyle: .glass,
            title: self.name,
            style: .left,
            checked: self.selected,
            zeroSeparatorInsets: false,
            sectionId: self.section,
            action: {
                arguments.select(self.attribute)
            }
        )
    }
}

private func stuxnetGiftVariantSelectionController(
    context: AccountContext,
    title: String,
    kind: StuxnetGiftVariantKind,
    variants: [StarGift.UniqueGift.Attribute],
    selectedName: String,
    select: @escaping (StarGift.UniqueGift.Attribute) -> Void
) -> ViewController {
    var dismissImpl: (() -> Void)?
    let candidates = variants.filter { stuxnetAttributeName($0, kind: kind) != nil }
    let arguments = StuxnetGiftVariantSelectionArguments(select: { attribute in
        select(attribute)
        dismissImpl?()
    })
    let signal = context.sharedContext.presentationData
    |> deliverOnMainQueue
    |> map { presentationData -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var presentationData = presentationData
        presentationData = presentationData.withUpdated(theme: presentationData.theme.withModalBlocksBackground())
        let entries: [StuxnetGiftVariantSelectionEntry] = candidates.enumerated().compactMap { index, attribute in
            guard let name = stuxnetAttributeName(attribute, kind: kind) else {
                return nil
            }
            return StuxnetGiftVariantSelectionEntry(index: Int32(index), name: name, attribute: attribute, selected: name == selectedName)
        }
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text(title),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks,
            animateChanges: false
        )
        return (controllerState, (listState, arguments))
    }
    let controller = ItemListController(context: context, state: signal)
    dismissImpl = { [weak controller] in
        controller?.navigationController?.popViewController(animated: true)
    }
    return controller
}

private func stuxnetGiftEditorEntries(gift: StuxnetLocalGift, state: StuxnetGiftEditorState) -> [StuxnetGiftEditorEntry] {
    let number = gift.number.map { " #\($0)" } ?? ""
    var entries: [StuxnetGiftEditorEntry] = [
        .header("\(gift.title)\(number)"),
        .preview,
        .visible(gift.visible),
        .pinned(gift.pinned),
        .equipped(gift.equipped),
        .number(gift.number.map { "\($0)" } ?? ""),
        .variantsHeader
    ]
    let hasModel = state.variants.contains { stuxnetAttributeName($0, kind: .model) != nil }
    let hasPattern = state.variants.contains { stuxnetAttributeName($0, kind: .pattern) != nil }
    let hasBackdrop = state.variants.contains { stuxnetAttributeName($0, kind: .backdrop) != nil }
    entries.append(.model(gift.model, hasModel))
    entries.append(.pattern(gift.symbol, hasPattern))
    entries.append(.backdrop(gift.background, hasBackdrop))
    entries.append(.color(state.colorInput ?? stuxnetGiftColorString(gift.color), gift.color))
    entries.append(.resetVariants)
    entries.append(.ownershipHeader)
    entries.append(.owner(gift.localOwner))
    for (index, transfer) in gift.transfers.suffix(10).reversed().enumerated() {
        let date = Date(timeIntervalSince1970: TimeInterval(transfer.timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        entries.append(.transferHistory(Int32(index), "→ \(transfer.recipient) · \(formatter.string(from: date))"))
    }
    if let status = state.status { entries.append(.status(status)) }
    entries.append(.remove)
    entries.append(.info)
    return entries
}

private func stuxnetLocalGiftEditorController(context: AccountContext, giftId: String) -> ViewController {
    let initialState = StuxnetGiftEditorState()
    let stateValue = Atomic(value: initialState)
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let updateState: ((StuxnetGiftEditorState) -> StuxnetGiftEditorState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    let currentGift = Atomic<StuxnetLocalGift?>(value: nil)

    func updateGift(_ f: @escaping (inout StuxnetLocalGift) -> Void) {
        let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { settings in
            var updated = settings
            guard let index = updated.localGifts.firstIndex(where: { $0.id == giftId }) else { return updated }
            f(&updated.localGifts[index])
            return updated
        }).startStandalone()
    }

    func applyVariant(_ kind: StuxnetGiftVariantKind, attribute: StarGift.UniqueGift.Attribute) {
        guard currentGift.with({ $0 }) != nil else { return }
        let variants = stateValue.with { $0.variants }
        updateGift { value in
            if value.previewAttributes.isEmpty {
                value.previewAttributes = stuxnetOriginalAttributes(value)
                if value.previewAttributes.isEmpty {
                    for variantKind in [StuxnetGiftVariantKind.model, .pattern, .backdrop] {
                        if let attribute = variants.first(where: { stuxnetAttributeName($0, kind: variantKind) != nil }) {
                            value.previewAttributes.append(attribute)
                        }
                    }
                }
            }
            value.previewAttributes.removeAll(where: { stuxnetAttributeName($0, kind: kind) != nil })
            value.previewAttributes.append(attribute)
            if let name = stuxnetAttributeName(attribute, kind: kind) {
                switch kind {
                case .model: value.model = name
                case .pattern: value.symbol = name
                case .backdrop:
                    value.background = name
                    if case let .backdrop(_, _, _, outerColor, _, _, _) = attribute {
                        value.color = UInt32(bitPattern: outerColor)
                    }
                }
            }
        }
        if case .backdrop = kind {
            updateState { current in
                var updated = current
                updated.colorInput = nil
                updated.status = nil
                return updated
            }
        }
    }

    func applyCustomColor(_ color: UInt32) {
        updateGift { gift in
            gift.color = color
            if gift.previewAttributes.isEmpty {
                gift.previewAttributes = stuxnetOriginalAttributes(gift)
            }
            if let index = gift.previewAttributes.firstIndex(where: {
                if case .backdrop = $0 {
                    return true
                } else {
                    return false
                }
            }), case let .backdrop(name, id, innerColor, _, patternColor, textColor, rarity) = gift.previewAttributes[index] {
                gift.previewAttributes[index] = .backdrop(
                    name: name,
                    id: id,
                    innerColor: innerColor,
                    outerColor: Int32(bitPattern: color),
                    patternColor: patternColor,
                    textColor: textColor,
                    rarity: rarity
                )
            }
        }
    }

    var presentControllerImpl: ((ViewController) -> Void)?
    var pushControllerImpl: ((ViewController) -> Void)?
    var dismissImpl: (() -> Void)?
    let arguments = StuxnetGiftEditorArguments(
        preview: {
            guard let gift = currentGift.with({ $0 }), let sourceGift = gift.sourceGift else { return }
            presentControllerImpl?(stuxnetGiftPreviewController(context: context, gift: sourceGift, attributes: gift.previewAttributes))
        },
        updateVisible: { value in
            updateGift {
                $0.visible = value
                if !value {
                    $0.pinned = false
                    $0.equipped = false
                }
            }
        },
        updatePinned: { value in
            let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { settings in
                var updated = settings
                guard let targetIndex = updated.localGifts.firstIndex(where: { $0.id == giftId }) else {
                    return updated
                }
                let ownerPeerId = updated.localGifts[targetIndex].localOwnerPeerId
                for index in updated.localGifts.indices {
                    if updated.localGifts[index].id == giftId {
                        updated.localGifts[index].pinned = value
                        if value { updated.localGifts[index].visible = true }
                    } else if value && updated.localGifts[index].localOwnerPeerId == ownerPeerId {
                        updated.localGifts[index].pinned = false
                    }
                }
                return updated
            }).startStandalone()
        },
        updateEquipped: { value in
            let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { settings in
                var updated = settings
                guard let targetIndex = updated.localGifts.firstIndex(where: { $0.id == giftId }) else {
                    return updated
                }
                let ownerPeerId = updated.localGifts[targetIndex].localOwnerPeerId
                for index in updated.localGifts.indices {
                    if updated.localGifts[index].id == giftId {
                        updated.localGifts[index].equipped = value
                        if value { updated.localGifts[index].visible = true }
                    } else if value && updated.localGifts[index].localOwnerPeerId == ownerPeerId {
                        updated.localGifts[index].equipped = false
                    }
                }
                return updated
            }).startStandalone()
        },
        updateNumber: { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            updateGift { gift in
                if trimmed.isEmpty {
                    if case let .unique(source) = gift.sourceGift {
                        gift.number = source.number
                    } else {
                        gift.number = nil
                    }
                } else if let number = Int32(trimmed), number > 0 {
                    gift.number = number
                }
            }
        },
        updateColor: { value in
            let value = String(value.prefix(7))
            updateState { current in
                var updated = current
                updated.colorInput = value
                let normalizedCount = value.trimmingCharacters(in: CharacterSet(charactersIn: "# ")).count
                if normalizedCount >= 6 && stuxnetParseGiftColor(value) == nil {
                    updated.status = "Use a 6-digit hex color, for example #8B5CF6."
                } else {
                    updated.status = nil
                }
                return updated
            }
            if let color = stuxnetParseGiftColor(value) {
                applyCustomColor(color)
            }
        },
        selectOwner: {
            guard currentGift.with({ $0 }) != nil else {
                return
            }
            let selectionController = context.sharedContext.makePeerSelectionController(PeerSelectionControllerParams(
                context: context,
                filter: [.onlyPrivateChats, .excludeSecretChats, .excludeSavedMessages, .excludeBots, .doNotSearchMessages],
                hasFilters: false,
                title: "Choose new owner",
                hasCreation: false,
                excludedPeerIds: [context.account.peerId]
            ))
            selectionController.peerSelected = { [weak selectionController] peer, _ in
                guard case .user = peer, let gift = currentGift.with({ $0 }) else {
                    return
                }
                selectionController?.dismiss()
                let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                let recipient = peer.displayTitle(strings: presentationData.strings, displayOrder: presentationData.nameDisplayOrder)
                let recipientPeerId = peer.id
                let number = gift.number.map { " #\($0)" } ?? ""
                Queue.mainQueue().after(0.25) {
                    presentControllerImpl?(textAlertController(
                        context: context,
                        title: "Transfer \(gift.title)\(number)?",
                        text: "\(recipient) will be shown as the owner. A gift event will appear in this chat.",
                        actions: [
                            TextAlertAction(type: .genericAction, title: presentationData.strings.Common_Cancel, action: {}),
                            TextAlertAction(type: .defaultAction, title: "Transfer", action: {
                                let timestamp = Int32(Date().timeIntervalSince1970)
                                let messageText = "🎁 \(gift.title)\(number) transferred to \(recipient)."
                                let _ = context.account.postbox.transaction { transaction -> Void in
                                    updateStuxnetSettings(transaction: transaction, { settings in
                                        var updated = settings
                                        guard let index = updated.localGifts.firstIndex(where: { $0.id == giftId }) else {
                                            return updated
                                        }
                                        updated.localGifts[index].localOwner = recipient
                                        updated.localGifts[index].localOwnerPeerId = recipientPeerId.toInt64()
                                        updated.localGifts[index].pinned = false
                                        updated.localGifts[index].equipped = false
                                        updated.localGifts[index].transfers.append(StuxnetLocalGiftTransfer(recipient: recipient, recipientPeerId: recipientPeerId.toInt64(), timestamp: timestamp))
                                        return updated
                                    })
                                    let (tags, globalTags) = tagsForStoreMessage(incoming: false, attributes: [], media: [], textEntities: nil, isPinned: false)
                                    var randomId = Int64.random(in: Int64.min ... Int64.max)
                                    if randomId == 0 {
                                        randomId = 1
                                    }
                                    let message = StoreMessage(
                                        peerId: recipientPeerId,
                                        namespace: Namespaces.Message.Local,
                                        customStableId: nil,
                                        globallyUniqueId: randomId,
                                        groupingKey: nil,
                                        threadId: nil,
                                        timestamp: timestamp,
                                        flags: StoreMessageFlags(),
                                        tags: tags,
                                        globalTags: globalTags,
                                        localTags: [],
                                        forwardInfo: nil,
                                        authorId: context.account.peerId,
                                        text: messageText,
                                        attributes: [],
                                        media: []
                                    )
                                    let _ = transaction.addMessages([message], location: .Random)
                                }.startStandalone()
                                updateState { current in
                                    var updated = current
                                    updated.status = "Transferred to \(recipient)."
                                    return updated
                                }
                            })
                        ]
                    ))
                }
            }
            pushControllerImpl?(selectionController)
        },
        selectModel: {
            guard let gift = currentGift.with({ $0 }) else { return }
            let variants = stateValue.with { $0.variants }
            pushControllerImpl?(stuxnetGiftVariantSelectionController(context: context, title: "Model", kind: .model, variants: variants, selectedName: gift.model, select: { applyVariant(.model, attribute: $0) }))
        },
        selectPattern: {
            guard let gift = currentGift.with({ $0 }) else { return }
            let variants = stateValue.with { $0.variants }
            pushControllerImpl?(stuxnetGiftVariantSelectionController(context: context, title: "Symbol", kind: .pattern, variants: variants, selectedName: gift.symbol, select: { applyVariant(.pattern, attribute: $0) }))
        },
        selectBackdrop: {
            guard let gift = currentGift.with({ $0 }) else { return }
            let variants = stateValue.with { $0.variants }
            pushControllerImpl?(stuxnetGiftVariantSelectionController(context: context, title: "Backdrop", kind: .backdrop, variants: variants, selectedName: gift.background, select: { applyVariant(.backdrop, attribute: $0) }))
        },
        resetVariants: {
            updateGift { gift in
                gift.previewAttributes = stuxnetOriginalAttributes(gift)
                if let source = gift.sourceGift {
                    let original = StuxnetLocalGift.imported(gift: source)
                    gift.model = original.model
                    gift.symbol = original.symbol
                    gift.background = original.background
                    gift.color = original.color
                }
            }
            updateState { current in
                var updated = current
                updated.colorInput = nil
                updated.status = nil
                return updated
            }
        },
        remove: {
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            presentControllerImpl?(textAlertController(
                context: context,
                title: "Remove gift?",
                text: "This removes the gift from your Stuxnet profile collection and its local transfer history.",
                actions: [
                    TextAlertAction(type: .genericAction, title: presentationData.strings.Common_Cancel, action: {}),
                    TextAlertAction(type: .destructiveAction, title: "Remove", action: {
                        let _ = updateStuxnetSettingsInteractively(postbox: context.account.postbox, { settings in
                            var updated = settings
                            updated.localGifts.removeAll(where: { $0.id == giftId })
                            return updated
                        }).startStandalone()
                        dismissImpl?()
                    })
                ]
            ))
        }
    )

    let giftSignal = stuxnetSettings(postbox: context.account.postbox)
    |> map { settings in settings.localGifts.first(where: { $0.id == giftId }) }
    |> distinctUntilChanged

    let signal = combineLatest(context.sharedContext.presentationData, statePromise.get(), giftSignal)
    |> deliverOnMainQueue
    |> map { presentationData, state, gift -> (ItemListControllerState, (ItemListNodeState, Any)) in
        _ = currentGift.swap(gift)
        var presentationData = presentationData
        presentationData = presentationData.withUpdated(theme: presentationData.theme.withModalBlocksBackground())
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(gift?.title ?? "Gift"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let entries: [StuxnetGiftEditorEntry] = gift.map { stuxnetGiftEditorEntries(gift: $0, state: state) } ?? [.status("Gift was removed.")]
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, animateChanges: true)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] value in controller?.present(value, in: .window(.root)) }
    pushControllerImpl = { [weak controller] value in controller?.push(value) }
    dismissImpl = { [weak controller] in controller?.navigationController?.popViewController(animated: true) }

    if let gift = currentGift.with({ $0 }), let giftId = gift.catalogGiftId {
        let _ = (context.engine.payments.starGiftUpgradePreview(giftId: giftId)
        |> deliverOnMainQueue).start(next: { preview in
            updateState { current in
                var updated = current
                updated.variants = preview?.attributes ?? []
                return updated
            }
        })
    } else {
        let _ = (giftSignal |> take(1) |> deliverOnMainQueue).start(next: { gift in
            guard let gift, let catalogGiftId = gift.catalogGiftId else { return }
            let _ = (context.engine.payments.starGiftUpgradePreview(giftId: catalogGiftId)
            |> deliverOnMainQueue).start(next: { preview in
                updateState { current in
                    var updated = current
                    updated.variants = preview?.attributes ?? []
                    return updated
                }
            })
        })
    }
    return controller
}
