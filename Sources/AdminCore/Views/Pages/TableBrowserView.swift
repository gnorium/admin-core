#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// Routing and behavior options for ``TableBrowserView`` and related row pages.
  public struct TableBrowserConfig: Sendable {
    /// Base URL for this table’s browser routes.
    public let baseURL: String
    /// URL for the “back” control.
    public let backURL: String
    /// Label for the “back” control.
    public let backLabel: String
    /// When `true`, bulk edit/delete and row edit affordances are shown.
    public let editable: Bool
    /// Column name used as the row primary key (default `"id"`).
    public let primaryKey: String

    /// Creates table browser configuration.
    public init(
      baseURL: String = "/admin-console/database",
      backURL: String = "/admin-console/database",
      backLabel: String = "Back to tables",
      editable: Bool = true,
      primaryKey: String = "id"
    ) {
      self.baseURL = baseURL
      self.backURL = backURL
      self.backLabel = backLabel
      self.editable = editable
      self.primaryKey = primaryKey
    }
  }

  /// One row of cell values for ``TableBrowserView``.
  public struct TableRowData: Sendable {
    /// Column name → display value.
    public let cells: [String: String]

    /// Creates a browser row.
    public init(cells: [String: String]) {
      self.cells = cells
    }
  }

  /// Paginated browser for a single database table (columns + rows).
  ///
  /// Pair with `TableBrowserHydration` on the WASM client for selection-driven bulk actions.
  public struct TableBrowserView: HTMLContent {
    let tableName: String
    let columns: [String]
    let rows: [TableRowData]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
    let config: TableBrowserConfig

    /// - Parameters:
    ///   - tableName: Table name shown in the header.
    ///   - columns: Column names (order defines column order).
    ///   - rows: Current page of rows.
    ///   - totalCount: Total row count across pages.
    ///   - currentPage: 1-based page index.
    ///   - totalPages: Total number of pages.
    ///   - config: URLs and editability.
    public init(
      tableName: String,
      columns: [String],
      rows: [TableRowData],
      totalCount: Int,
      currentPage: Int = 1,
      totalPages: Int = 1,
      config: TableBrowserConfig = TableBrowserConfig()
    ) {
      self.tableName = tableName
      self.columns = columns
      self.rows = rows
      self.totalCount = totalCount
      self.currentPage = currentPage
      self.totalPages = totalPages
      self.config = config
    }

    public func build() -> DOM.Node {
      let tableColumns: [TableView.Column] =
        [
          TableView.Column(id: "#", label: "#", width: px(50))
        ]
        + columns.map { column in
          TableView.Column(id: column, label: column, width: px(150))
        }

      let tableRows: [TableView.Row] = rows.enumerated().map { (index, row) in
        let rowID = row.cells[config.primaryKey] ?? "\(index)"
        var cells: [String: String] = ["#": "\((currentPage - 1) * 50 + index + 1)"]
        for column in columns {
          cells[column] = truncateValue(row.cells[column] ?? "")
        }
        return TableView.Row(id: rowID, cells: cells)
      }

      return section {
        // Header
        header {
          h1 { tableName }
            .class("table-browser-title")

          p { "\(totalCount) rows" }
            .class("table-browser-subtitle")
        }
        .class("table-browser-header")

        TableView(
          captionContent: tableName,
          hideCaption: true,
          columns: tableColumns,
          data: tableRows,
          selectionMode: config.editable ? .multiple : nil,
          class: "table-browser-data"
        ) {
          // Action toolbar
          if config.editable {
            div {
              span { "0 selected" }
                .class("selection-count")

              ButtonGroupView(
                buttons: [
                  .init(value: "edit", label: "Edit", disabled: true, class: "action-edit"),
                  .init(value: "delete", label: "Delete", disabled: true, class: "action-delete"),
                ],
                class: "action-buttons"
              )
            }
            .class("table-action-toolbar")
            .data("table", tableName)
            .data("base-url", config.baseURL)
            .data("primary-key", config.primaryKey)
          }
        } emptyState: {
          div { "No data" }
            .class("table-browser-empty-title")
          div { "This table has no rows" }
            .class("table-browser-empty-description")
        }.render()

        // Pagination
        if totalPages > 1 {
          PaginationView(
            previousUrl: currentPage > 1
              ? "\(config.baseURL)/\(tableName)?page=\(currentPage - 1)" : nil,
            nextUrl: currentPage < totalPages
              ? "\(config.baseURL)/\(tableName)?page=\(currentPage + 1)" : nil,
            pageNumbers: buildPageNumbers(),
            class: "table-browser-pagination"
          )
        }
      }
      .class("table-browser-view")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
        }
        descendant(".table-browser-header") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
          paddingBlockEnd(spacing24)
          borderBlockEnd(borderWidthBase, .solid, borderColorSubtle)
        }
        descendant(".table-browser-title") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeXXLarge24)
          color(colorBase)
          margin(0)
        }
        descendant(".table-browser-subtitle") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          margin(0)
        }
        descendant(".selection-count") {
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          fontFamily(typographyFontMono)
        }
        descendant(".table-action-toolbar") {
          display(.flex)
          justifyContent(.spaceBetween)
          alignItems(.center)
          width(perc(100))
        }
        descendant(".table-browser-empty-title") {
          fontSize(fontSizeLarge18)
          fontWeight(fontWeightSemiBold)
          marginBlockEnd(spacing8)
        }
        descendant(".table-browser-empty-description") { color(colorSubtle) }
        descendant(".table-browser-data .table-row") { cursor(.pointer) }
      }
    }

    private func buildPageNumbers() -> [PaginationView.PageNumber] {
      var pages: [PaginationView.PageNumber] = []
      let baseUrl = "\(config.baseURL)/\(tableName)?page="

      // Show up to 7 page numbers with ellipsis-like windowing
      let windowSize = 2
      let start = max(1, currentPage - windowSize)
      let end = min(totalPages, currentPage + windowSize)

      if start > 1 {
        pages.append(
          PaginationView.PageNumber(label: "1", url: "\(baseUrl)1", isActive: currentPage == 1))
        if start > 2 {
          pages.append(PaginationView.PageNumber(label: "…", url: "", isActive: false))
        }
      }

      for p in start...end {
        pages.append(
          PaginationView.PageNumber(
            label: "\(p)", url: "\(baseUrl)\(p)", isActive: p == currentPage))
      }

      if end < totalPages {
        if end < totalPages - 1 {
          pages.append(PaginationView.PageNumber(label: "…", url: "", isActive: false))
        }
        pages.append(
          PaginationView.PageNumber(
            label: "\(totalPages)", url: "\(baseUrl)\(totalPages)",
            isActive: currentPage == totalPages))
      }

      return pages
    }

    private func truncateValue(_ value: String) -> String {
      if value.count > 50 {
        return String(value.prefix(47)) + "..."
      }
      return value
    }
  }
#endif

#if CLIENT
  import DOMBuilder
  import EmbeddedSwiftUtilities
  import HTMLBuilder
  import WebAPIs
  import WebTypes

  /// Client hydration for ``TableBrowserView`` (bulk actions, row navigation, selection count).
  public class TableBrowserHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: TableBrowserHydration?

    public static func hydrateIfPresent() {
      guard document.querySelector(".table-browser-view") != nil else { return }
      instance = TableBrowserHydration()
    }

    private var selectionCountEl: DOM.Element?
    private var editButton: DOM.Element?
    private var deleteButton: DOM.Element?
    private var selectedRowIDs: [String] = []
    private var tableName: String = ""
    private var baseURL: String = ""

    public init() {
      hydrate()
    }

    private func hydrate() {
      guard let tableView = document.querySelector(".table-browser-data") else { return }

      // Get config from toolbar data attributes
      if let toolbar = document.querySelector(".table-action-toolbar") {
        tableName = toolbar.getAttribute(data("table")) ?? ""
        baseURL = toolbar.getAttribute(data("base-url")) ?? ""
      }

      selectionCountEl = document.querySelector(".selection-count")
      editButton = document.querySelector(".action-edit")
      deleteButton = document.querySelector(".action-delete")

      // Listen for selection changes from TableView
      _ = tableView.addEventListener("table-selection-change") { [self] (event: Event) in
        let detail = event.detail
        if detail.isEmpty {
          self.selectedRowIDs = []
        } else {
          self.selectedRowIDs = stringSplit(detail, separator: ",")
        }
        self.updateButtonStates()
      }

      // Edit button
      if let editBtn = editButton {
        _ = editBtn.addEventListener(.click) { [self] (event: Event) in
          guard self.selectedRowIDs.count == 1, let rowID = self.selectedRowIDs.first else {
            return
          }
          window.location.href = "\(self.baseURL)/\(self.tableName)/\(rowID)/edit"
        }
      }

      // Delete button
      if let deleteBtn = deleteButton {
        _ = deleteBtn.addEventListener(.click) { [self] (event: Event) in
          guard !self.selectedRowIDs.isEmpty else { return }
          let count = self.selectedRowIDs.count
          let message =
            count == 1
            ? "Are you sure you want to delete this row?"
            : "Are you sure you want to delete \(count) rows?"
          if window.confirm(message) {
            let idsParam = stringJoin(self.selectedRowIDs, separator: ",")
            window.location.href = "\(self.baseURL)/\(self.tableName)/delete?ids=\(idsParam)"
          }
        }
      }

      // Clickable rows — navigate to row detail view
      let rows = tableView.querySelectorAll(".table-row")
      for row in rows {
        _ = row.addEventListener(.click) { [self] (event: Event) in
          if let target = event.target {
            let tag = target.tagName
            if stringEquals(tag, "INPUT") || stringEquals(tag, "LABEL") {
              return
            }
          }
          if let rowID = row.getAttribute("data-row-id") {
            window.location.href = "\(self.baseURL)/\(self.tableName)/\(rowID)"
          }
        }
      }
    }

    private func updateButtonStates() {
      let count = selectedRowIDs.count

      // Re-query ensuring we have the latest elements from the DOM
      let countEl = document.querySelector(".selection-count")
      let editBtn = document.querySelector(".action-edit")
      let deleteBtn = document.querySelector(".action-delete")

      if let el = countEl {
        el.textContent = "\(count) selected"
      }

      if let btn = editBtn {
        (btn as? HTML.HTMLButtonElement)?.disabled = (count != 1)
      }

      if let btn = deleteBtn {
        (btn as? HTML.HTMLButtonElement)?.disabled = (count == 0)
      }
    }
  }
#endif
