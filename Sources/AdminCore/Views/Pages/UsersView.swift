#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// User data for display in UsersView
public struct UserRow: Sendable {
	public let id: String
	public let username: String
	public let email: String?
	public let role: String
	public let status: String
	public let mfaEnabled: Bool
	public let joinedDate: String

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

/// Statistics for UsersView header
public struct UserStats: Sendable {
	public let total: Int
	public let admins: Int
	public let active: Int

	public init(total: Int, admins: Int = 0, active: Int = 0) {
		self.total = total
		self.admins = admins
		self.active = active
	}
}

/// Configuration for UsersView
public struct UsersViewConfig: Sendable {
	public let title: String
	public let subtitle: String
	public let baseURL: String
	public let showMFAColumn: Bool
	public let bulkActions: [BulkAction]

	public struct BulkAction: Sendable {
		public let label: String
		public let cssClass: String

		public init(label: String, cssClass: String) {
			self.label = label
			self.cssClass = cssClass
		}
	}

	public init(
		title: String = "Users",
		subtitle: String = "Manage user accounts, roles, and security",
		baseURL: String = "/admin-console/users",
		showMFAColumn: Bool = true,
		bulkActions: [BulkAction] = [
			BulkAction(label: "Suspend", cssClass: "bulk-suspend-btn"),
			BulkAction(label: "Ban", cssClass: "bulk-ban-btn")
		]
	) {
		self.title = title
		self.subtitle = subtitle
		self.baseURL = baseURL
		self.showMFAColumn = showMFAColumn
		self.bulkActions = bulkActions
	}
}

/// Generic Users management view for admin consoles
/// Uses TableView with row selection for bulk actions
public struct UsersView: HTMLProtocol {
	let users: [UserRow]
	let stats: UserStats
	let config: UsersViewConfig
	let currentPage: Int
	let totalPages: Int

	public init(
		users: [UserRow],
		stats: UserStats? = nil,
		config: UsersViewConfig = UsersViewConfig(),
		currentPage: Int = 1,
		totalPages: Int = 1
	) {
		self.users = users
		self.stats = stats ?? UserStats(
			total: users.count,
			admins: users.filter { $0.role.lowercased() == "admin" }.count,
			active: users.filter { $0.status.lowercased() == "active" }.count
		)
		self.config = config
		self.currentPage = currentPage
		self.totalPages = totalPages
	}

	public func render(indent: Int = 0) -> String {
		section {
			// Header
			header {
				h1 { config.title }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeXXXLarge28)
					color(colorBase)
					margin(0)
				}

				p { config.subtitle }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeSmall14)
					color(colorSubtle)
					margin(0)
				}
			}
			.class("users-header")
			.style {
				display(.flex)
				flexDirection(.column)
				gap(spacing8)
				paddingBottom(spacing32)
				borderBottom(borderWidthBase, .solid, borderColorSubtle)
			}

			// Stats row
			div {
				renderStatBadge("Total", stats.total)
				renderStatBadge("Admins", stats.admins)
				renderStatBadge("Active", stats.active)
			}
			.style {
				display(.flex)
				gap(spacing16)
			}

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
							size: .large,
							disabled: true,
							class: action.cssClass
						)
					}
				}
				.class("users-actions")
				.style {
					display(.flex)
					gap(spacing8)
					justifyContent(.flexEnd)
					width(perc(100))
				}
			} thead: {
			} tbody: {
			} tfoot: {
			} footer: {
				// Pagination
				if totalPages > 1 {
					div {
						span { "Page \(currentPage) of \(totalPages)" }
						.style {
							fontSize(fontSizeSmall14)
							color(colorSubtle)
						}
					}
					.style {
						display(.flex)
						justifyContent(.center)
						paddingTop(spacing16)
					}
				}
			} emptyState: {
				div { "No users found" }
				.style {
					fontSize(fontSizeLarge18)
					fontWeight(fontWeightNormal)
					marginBottom(spacing8)
				}
				div { "Users will appear here when accounts are created" }
				.style {
					color(colorSubtle)
				}
			}
		}
		.class("users-container")
		.style {
			display(.flex)
			flexDirection(.column)
			gap(spacing32)
		}
		.render(indent: indent)
	}

	private func buildColumns() -> [TableView.Column] {
		var columns = [
			TableView.Column(id: "user", label: "User"),
			TableView.Column(id: "role", label: "Role"),
			TableView.Column(id: "status", label: "Status")
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
			"joined": user.joinedDate
		]
		if config.showMFAColumn {
			cells["mfa"] = user.mfaEnabled ? "Enabled" : "Disabled"
		}
		return cells
	}

	@HTMLBuilder
	private func renderStatBadge(_ label: String, _ value: Int) -> HTMLProtocol {
		div {
			span { label }
			.style {
				fontSize(fontSizeXSmall12)
				color(colorSubtle)
				textTransform(.uppercase)
				letterSpacing(px(0.5))
				fontWeight(fontWeightBold)
			}
			div { "\(value)" }
			.style {
				fontSize(fontSizeMedium16)
				color(colorBase)
				fontFamily(typographyFontSans)
				fontWeight(fontWeightNormal)
			}
		}
		.style {
			padding(spacing16, spacing24)
			backgroundColor(backgroundColorBase)
			border(borderWidthBase, .solid, borderColorSubtle)
			borderRadius(borderRadiusBase)
		}
	}
}

#endif

#if os(WASI)

import WebAPIs
import DesignTokens
import EmbeddedSwiftUtilities

/// Hydration for UsersView - enables bulk action buttons based on selection
public class UsersHydration: @unchecked Sendable {
	private var actionButtons: [Element] = []
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
		_ = usersTable.addEventListener("table-selection-change") { _ in
			self.updateButtonStates()
		}

		// Make table rows clickable
		let rows = usersTable.querySelectorAll(".table-row")
		for row in rows {
			row.style.cursor(.pointer)

			_ = row.addEventListener(.click) { event in
				if let target = event.target {
					let typeAttr = target.getAttribute("type") ?? ""
					if stringEquals(typeAttr, "checkbox") {
						return
					}
				}
				if let rowId = row.getAttribute("data-row-id") {
					window.location.href = "\(self.baseURL)/\(rowId)"
				}
			}
		}
	}

	private func updateButtonStates() {
		let checkboxes = document.querySelectorAll("[name='row-selection']")
		let selectedCount = checkboxes.filter { $0.checked }.count
		let hasSelection = selectedCount > 0

		for button in actionButtons {
			button.setDisabled(!hasSelection)
		}
	}
}

#endif
