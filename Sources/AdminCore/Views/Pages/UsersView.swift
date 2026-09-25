#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// One user row for ``UsersView``.
  public struct UserRow: Sendable {
    /// User id.
    public let id: String
    /// Username.
    public let username: String
    /// Optional email.
    public let email: String?
    /// Role label (e.g. `"Admin"`).
    public let role: String
    /// Status label (e.g. `"Active"`).
    public let status: String
    /// Whether MFA is enabled for the user.
    public let mfaEnabled: Bool
    /// Formatted join date for display.
    public let joinedDate: String

    /// Creates a user row.
    public init(
      id: String,
      username: String,
      email: String? = nil,
      role: String = "User",
      status: String = "Active",
      mfaEnabled: Bool = false,
      joinedDate: String = "N/A"
    ) {
      self.id = id
      self.username = username
      self.email = email
      self.role = role
      self.status = status
      self.mfaEnabled = mfaEnabled
      self.joinedDate = joinedDate
    }
  }

  /// Aggregate counts shown above ``UsersView``.
  public struct UserStats: Sendable {
    /// Total users.
    public let total: Int
    /// Admin-role count.
    public let admins: Int
    /// Active users count.
    public let active: Int

    /// Creates user stats.
    public init(total: Int, admins: Int = 0, active: Int = 0) {
      self.total = total
      self.admins = admins
      self.active = active
    }
  }

  /// Presentation options for ``UsersView``.
  public struct UsersViewConfig: Sendable {
    /// Page title.
    public let title: String
    /// Supporting subtitle.
    public let subtitle: String
    /// Base URL for user management routes.
    public let baseURL: String
    /// Whether to show the MFA column.
    public let showMFAColumn: Bool
    /// Bulk action buttons bound to table selection.
    public let bulkActions: [BulkAction]

    /// One bulk action button definition.
    public struct BulkAction: Sendable {
      /// Button label.
      public let label: String
      /// CSS class used by hydration to find the button.
      public let cssClass: String

      /// Creates a bulk action.
      public init(label: String, cssClass: String) {
        self.label = label
        self.cssClass = cssClass
      }
    }

    /// Creates users view configuration.
    public init(
      title: String = "Users",
      subtitle: String = "Manage user accounts, roles, and security",
      baseURL: String = "/admin-console/users",
      showMFAColumn: Bool = true,
      bulkActions: [BulkAction] = [
        BulkAction(label: "Suspend", cssClass: "bulk-suspend-btn"),
        BulkAction(label: "Ban", cssClass: "bulk-ban-btn"),
      ]
    ) {
      self.title = title
      self.subtitle = subtitle
      self.baseURL = baseURL
      self.showMFAColumn = showMFAColumn
      self.bulkActions = bulkActions
    }
  }

  /// User management table with stats header and bulk actions.
  ///
  /// Pair with `UsersHydration` on the WASM client for selection-driven buttons.
  public struct UsersView: HTMLContent {
    let users: [UserRow]
    let stats: UserStats
    let config: UsersViewConfig
    let currentPage: Int
    let totalPages: Int

    /// - Parameters:
    ///   - users: Current page of users.
    ///   - stats: Header stats; defaults are derived from `users` when omitted.
    ///   - config: Titles, URLs, and bulk actions.
    ///   - currentPage: 1-based page index.
    ///   - totalPages: Total number of pages.
    public init(
      users: [UserRow],
      stats: UserStats? = nil,
      config: UsersViewConfig = UsersViewConfig(),
      currentPage: Int = 1,
      totalPages: Int = 1
    ) {
      self.users = users
      self.stats =
        stats
        ?? UserStats(
          total: users.count,
          admins: users.filter { $0.role.lowercased() == "admin" }.count,
          active: users.filter { $0.status.lowercased() == "active" }.count
        )
      self.config = config
      self.currentPage = currentPage
      self.totalPages = totalPages
    }

    public func build() -> DOM.Node {
      section {
        // Header
        header {
          h1 { config.title }
            .class("users-title")

          p { config.subtitle }
            .class("users-subtitle")
        }
        .class("users-header")

        // Stats row
        div {
          renderStatBadge("Total", stats.total)
          renderStatBadge("Admins", stats.admins)
          renderStatBadge("Active", stats.active)
        }
        .class("users-stats")

        // Users table with row selection
        TableView(
          captionContent: config.title,
          hideCaption: true,
          columns: buildColumns(),
          data: users.map { u in
            TableView.Row(
              id: u.id,
              cells: buildCells(for: u)
            )
          },
          selectionMode: TableView.SelectionMode.multiple,
          class: "users-table"
        ) {
          // Bulk action buttons
          div {
            for action in config.bulkActions {
              ButtonView(
                label: action.label,
                buttonColor: .gray,
                weight: .subtle,
                size: .medium,
                disabled: true,
                class: action.cssClass
              )
            }
          }
          .class("users-actions")
        } thead: {
        } tbody: {
        } tfoot: {
        } footer: {
          // Pagination
          if totalPages > 1 {
            div {
              span { "Page \(currentPage) of \(totalPages)" }
                .class("users-pagination-label")
            }
            .class("users-pagination")
          }
        } emptyState: {
          div { "No users found" }
            .class("users-empty-title")
          div { "Users will appear here when accounts are created" }
            .class("users-empty-description")
        }
        .render()
      }
      .class("users-view")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing32)
        }
        descendant(".users-header") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
          paddingBottom(spacing32)
          borderBottom(borderWidthBase, .solid, borderColorSubtle)
        }
        descendant(".users-title") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeXXXLarge28)
          color(colorBase)
          margin(0)
        }
        descendant(".users-subtitle") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          margin(0)
        }
        descendant(".users-stats") {
          display(.flex)
          gap(spacing16)
        }
        descendant(".users-actions") {
          display(.flex)
          gap(spacing8)
          justifyContent(.flexEnd)
          width(perc(100))
        }
        descendant(".users-pagination") {
          display(.flex)
          justifyContent(.center)
          paddingTop(spacing16)
        }
        descendant(".users-pagination-label") {
          fontSize(fontSizeSmall14)
          color(colorSubtle)
        }
        descendant(".users-empty-title") {
          fontSize(fontSizeLarge18)
          fontWeight(fontWeightNormal)
          marginBottom(spacing8)
        }
        descendant(".users-empty-description") { color(colorSubtle) }
        descendant(".users-stat") {
          padding(spacing16, spacing24)
          backgroundColor(backgroundColorBase)
          border(borderWidthBase, .solid, borderColorSubtle)
          borderRadius(borderRadiusBase)
        }
        descendant(".users-stat-label") {
          fontSize(fontSizeXSmall12)
          color(colorSubtle)
          textTransform(.uppercase)
          letterSpacing(px(0.5))
          fontWeight(fontWeightSemiBold)
        }
        descendant(".users-stat-value") {
          fontSize(fontSizeMedium16)
          color(colorBase)
          fontFamily(typographyFontSans)
          fontWeight(fontWeightNormal)
        }
        descendant(".users-table .table-row") { cursor(.pointer) }
      }
    }

    private func buildColumns() -> [TableView.Column] {
      var columns = [
        TableView.Column(id: "user", label: "User"),
        TableView.Column(id: "role", label: "Role"),
        TableView.Column(id: "status", label: "Status"),
      ]
      if config.showMFAColumn {
        columns.append(TableView.Column(id: "mfa", label: "MFA"))
      }
      columns.append(TableView.Column(id: "joined", label: "Joined"))
      return columns
    }

    private func buildCells(for user: UserRow) -> [String: String] {
      var cells: [String: String] = [
        "user": user.username,
        "role": user.role,
        "status": user.status,
        "joined": user.joinedDate,
      ]
      if config.showMFAColumn {
        cells["mfa"] = user.mfaEnabled ? "Enabled" : "Disabled"
      }
      return cells
    }

    @HTMLBuilder
    private func renderStatBadge(_ label: String, _ value: Int) -> [DOM.Node] {
      div {
        span { label }
          .class("users-stat-label")
        div { "\(value)" }
          .class("users-stat-value")
      }
      .class("users-stat")
    }
  }
#endif

#if CLIENT
  import DOMBuilder
  import EmbeddedSwiftUtilities
  import HTMLBuilder
  import WebAPIs
  import WebTypes

  /// Client hydration for ``UsersView`` bulk actions from table selection.
  public class UsersHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: UsersHydration?

    public static func hydrateIfPresent() {
      guard document.querySelector(".users-view") != nil else { return }
      instance = UsersHydration()
    }

    private var actionButtons: [DOM.Element] = []
    private var baseURL: String = "/admin-console/users"

    public init() {
      hydrate()
    }

    public func hydrate() {
      guard let usersTable = document.querySelector(".users-table") else { return }

      // Get base URL from current path
      let path = window.location.pathname
      if stringContains(path, "/users") {
        let parts = stringSplit(path, separator: "/users")
        if let basePart = parts.first {
          baseURL = basePart + "/users"
        }
      }

      // Find all bulk action buttons
      let buttons = document.querySelectorAll(".users-actions button")
      actionButtons = buttons

      // Listen for selection changes from TableView
      _ = usersTable.addEventListener("table-selection-change") { (event: Event) in
        self.updateButtonStates()
      }

      // Make table rows clickable
      let rows = usersTable.querySelectorAll(".table-row")
      for row in rows {
        _ = row.addEventListener(.click) { (event: Event) in
          if let target = event.target {
            let typeAttr = target.getAttribute(HTMLAttributeName.type) ?? ""
            if stringEquals(typeAttr, "checkbox") {
              return
            }
          }
          if let rowID = row.getAttribute(data("row-id")) {
            window.location.href = "\(self.baseURL)/\(rowID)"
          }
        }
      }
    }

    private func updateButtonStates() {
      let checkboxes = document.querySelectorAll("[name='row-selection']")
      let selectedCount = checkboxes.filter { ($0 as? HTML.HTMLInputElement)?.checked ?? false }.count
      let hasSelection = selectedCount > 0

      for button in actionButtons {
        (button as? HTML.HTMLButtonElement)?.disabled = !hasSelection
      }
    }
  }
#endif
