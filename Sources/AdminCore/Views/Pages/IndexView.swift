#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

private let baseRoute = Configuration.shared.baseRoute

/// Admin index view for listing model records with selection and bulk actions.
/// Uses TableView with row selection for consistent component usage.
public struct IndexView: HTMLContent {
    let admin: AnyModelAdmin
    let rows: [ListRow]
    
    public init(admin: AnyModelAdmin, rows: [ListRow]) {
        self.admin = admin
        self.rows = rows
    }
    
    public func render(indent: Int = 0) -> String {
        TableView(
            captionContent: "",
            hideCaption: true,
            columns: admin.listFields.map { field in
                TableView.Column(
                    id: field,
                    label: admin.listHeaders[field] ?? field.capitalized,
                    sortable: true
                )
            },
            data: rows.map { row in
                TableView.Row(
                    id: row.id,
                    cells: row.values
                )
            },
            selectionMode: TableView.SelectionMode.multiple,
            class: "index-view"
        ) {
            // Custom header with title and action buttons
            div {
                div {
                    // Bulk action buttons
                    ButtonView(label: "Edit", buttonColor: .gray, weight: .subtle, size: .large, disabled: true, class: "bulk-edit-btn")
                    
                    ButtonView(label: "Delete", buttonColor: .gray, weight: .subtle, size: .large, disabled: true, class: "bulk-delete-btn")

                    a {
                        ButtonView(label: "Add \(admin.modelName)", buttonColor: .blue, weight: .solid, size: .large)
                    }
                    .href("\(baseRoute)/\(admin.urlPath)/new")
                    .style { textDecoration(.none) }
                }
                .class("index-actions")
                .data("base-route", baseRoute)
                .data("url-path", admin.urlPath)
                .style {
                    display(.flex)
                    gap(spacing8)
                    alignItems(.center)
                }
            }
            .style {
                display(.flex)
                justifyContent(.flexEnd)
                alignItems(.center)
                width(perc(100))
                marginBottom(spacing24)
            }
        } thead: {
            // Use default thead from TableView
        } tbody: {
            // Use default tbody from TableView  
        } tfoot: {
        } footer: {
        } emptyState: {
            div { "No \(admin.modelNamePlural.lowercased()) found" }
            .style {
                fontSize(fontSizeLarge18)
                fontWeight(600)
                marginBottom(spacing8)
            }
            div { "Click 'Add \(admin.modelName)' above to create one" }
            .style {
                color(colorSubtle)
            }
        }
        .render(indent: indent)
    }
}

#endif

#if os(WASI)

import WebAPIs
import EmbeddedSwiftUtilities

/// Hydration for IndexView - extends TableView's selection with bulk action buttons
public class IndexHydration: @unchecked Sendable {
    private var editBtn: Element?
    private var deleteBtn: Element?
    private var baseRoute: String = ""
    private var urlPath: String = ""

    public init() {
        hydrate()
    }

    public func hydrate() {
        guard let indexRoot = document.querySelector(".index-view") else { return }
        
        // Read baseRoute and urlPath from server-rendered data attributes on .index-actions
        if let actions = document.querySelector(".index-actions") {
            baseRoute = actions.getAttribute("data-base-route") ?? "/admin-console"
            urlPath = actions.getAttribute("data-url-path") ?? ""
        }

        editBtn = document.querySelector(".bulk-edit-btn")
        deleteBtn = document.querySelector(".bulk-delete-btn")

        // Listen for selection changes from the TableView (dispatched as CustomEvent)
        _ = indexRoot.addEventListener("table-selection-change") { _ in
            self.updateButtonStates()
        }

        _ = editBtn?.addEventListener(.click) { _ in
            self.handleBulkEdit()
        }

        _ = deleteBtn?.addEventListener(.click) { _ in
            self.handleBulkDelete()
        }
    }

    private func updateButtonStates() {
        let checkboxes = document.querySelectorAll("[name='row-selection']")
        let selectedCount = checkboxes.filter { ($0 as? HTMLInputElement)?.checked ?? false }.count
        let hasSelection = selectedCount > 0
        let singleSelection = selectedCount == 1

        (editBtn as? HTMLButtonElement)?.disabled = !singleSelection
        (deleteBtn as? HTMLButtonElement)?.disabled = !hasSelection
    }

    private func getSelectedIDs() -> [String] {
        let checkboxes = document.querySelectorAll("[name='row-selection']")
        return checkboxes.compactMap { checkbox in
            (checkbox as? HTMLInputElement)?.checked == true ? (checkbox as? HTMLInputElement)?.value : nil
        }
    }

    private func handleBulkEdit() {
        let ids = getSelectedIDs()
        guard let firstID = ids.first else { return }
        window.location.href = "\(baseRoute)/\(urlPath)/\(firstID)/edit"
    }

    private func handleBulkDelete() {
        let ids = getSelectedIDs()
        guard !ids.isEmpty else { return }
        
        let count = ids.count
        let message = count == 1 ? "Are you sure you want to delete this item?" : "Are you sure you want to delete \(count) items?"
        
        let confirmed = window.confirm(message)
        if confirmed {
            let idsParam = stringJoin(ids, separator: ",")
            window.location.href = "\(baseRoute)/\(urlPath)/delete?ids=\(idsParam)"
        }
    }
}

#endif
