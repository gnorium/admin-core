#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// List view for a registered model: selectable rows and bulk edit/delete/add actions.
  ///
  /// Backed by `TableView` with multi-select; pair with `IndexHydration` on the WASM client.
  public struct IndexView: HTMLContent {
    let admin: AnyModelAdmin
    let rows: [ListRow]

    /// - Parameters:
    ///   - admin: Type-erased model admin (columns and labels).
    ///   - rows: Rows to display.
    public init(admin: AnyModelAdmin, rows: [ListRow]) {
      self.admin = admin
      self.rows = rows
    }

    public func build() -> DOM.Node {
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
          ButtonGroupView(
            buttons: [
              .init(value: "edit", label: "Edit", disabled: true, class: "bulk-edit-btn"),
              .init(value: "delete", label: "Delete", disabled: true, class: "bulk-delete-btn"),
              .init(
                value: "add", label: "Add \(admin.modelName)",
                url: "\(baseRoute)/\(admin.urlPath)/new",
                buttonColor: .blue, weight: .solid
              ),
            ],
            class: "index-actions",
            data: ["base-route": baseRoute, "url-path": admin.urlPath],
            style: {
              selector("&") {
                width(perc(100))
                justifyContent(.flexEnd)
              }
            }
          )
        }
        .class("index-header")
        .style {
          selector("&") {
            display(.flex)
            justifyContent(.flexEnd)
            alignItems(.center)
            width(perc(100))
          }
        }
      } thead: {
        // Use default thead from TableView
      } tbody: {
        // Use default tbody from TableView
      } tfoot: {
      } footer: {
      } emptyState: {
        div {
          div { "No \(admin.modelNamePlural.lowercased()) found" }
            .class("index-empty-title")
          div { "Click 'Add \(admin.modelName)' above to create one" }
            .class("index-empty-description")
        }
        .class("index-empty-state")
        .style {
          selector(".index-empty-title") {
            fontSize(fontSizeLarge18)
            fontWeight(600)
          }
          selector(".index-empty-description") {
            color(colorSubtle)
          }
        }
      }
      .render()

    }
  }
#endif

#if CLIENT
  import DOMBuilder
  import EmbeddedSwiftUtilities
  import HTMLBuilder
  import WebAPIs
  import WebTypes

  /// Client hydration for ``IndexView``: enables bulk actions from table selection.
  public class IndexHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: IndexHydration?

    public static func hydrateIfPresent() {
      guard document.querySelector(".index-view") != nil else { return }
      instance = IndexHydration()
    }

    private var editBtn: DOM.Element?
    private var deleteBtn: DOM.Element?
    private var baseRoute: String = ""
    private var urlPath: String = ""

    public init() {
      hydrate()
    }

    public func hydrate() {
      guard let indexRoot = document.querySelector(".index-view") else { return }

      // Read baseRoute and urlPath from server-rendered data attributes on .index-actions
      if let actions = document.querySelector(".index-actions") {
        baseRoute = actions.getAttribute(data("base-route")) ?? "/admin-console"
        urlPath = actions.getAttribute(data("url-path")) ?? ""
      }

      editBtn = document.querySelector(".bulk-edit-btn")
      deleteBtn = document.querySelector(".bulk-delete-btn")

      // Listen for selection changes from the TableView (dispatched as CustomEvent)
      _ = indexRoot.addEventListener("table-selection-change") { (event: Event) in
        self.updateButtonStates()
      }

      _ = editBtn?.addEventListener(.click) { (event: Event) in
        self.handleBulkEdit()
      }

      _ = deleteBtn?.addEventListener(.click) { (event: Event) in
        self.handleBulkDelete()
      }
    }

    private func updateButtonStates() {
      let checkboxes = document.querySelectorAll("[name='row-selection']")
      let selectedCount = checkboxes.filter { ($0 as? HTML.HTMLInputElement)?.checked ?? false }.count
      let hasSelection = selectedCount > 0
      let singleSelection = selectedCount == 1

      (editBtn as? HTML.HTMLButtonElement)?.disabled = !singleSelection
      (deleteBtn as? HTML.HTMLButtonElement)?.disabled = !hasSelection
    }

    private func getSelectedIDs() -> [String] {
      let checkboxes = document.querySelectorAll("[name='row-selection']")
      return checkboxes.compactMap { checkbox in
        (checkbox as? HTML.HTMLInputElement)?.checked == true
          ? (checkbox as? HTML.HTMLInputElement)?.value : nil
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
      let message =
        count == 1
        ? "Are you sure you want to delete this item?"
        : "Are you sure you want to delete \(count) items?"

      let confirmed = window.confirm(message)
      if confirmed {
        let idsParam = stringJoin(ids, separator: ",")
        // A POST, never a link: a GET that deletes can be triggered from
        // another site, which the sign-in cookie (SameSite=Lax) follows.
        let listURL = "\(baseRoute)/\(urlPath)"
        window.fetch("\(listURL)/delete", method: "POST", body: "ids=\(idsParam)") { _ in
          window.location.href = listURL
        }
      }
    }
  }
#endif
