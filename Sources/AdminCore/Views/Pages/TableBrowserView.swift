#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Configuration for TableBrowserView
public struct TableBrowserConfig: Sendable {
	public let baseURL: String
	public let backURL: String
	public let backLabel: String
	public let editable: Bool
	public let primaryKey: String

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

/// Data for a single table row in browser
public struct TableRowData: Sendable {
	public let cells: [String: String]

	public init(cells: [String: String]) {
		self.cells = cells
	}
}

/// Generic Table browser view for admin consoles
/// Displays rows from a database table with pagination
public struct TableBrowserView: HTMLProtocol {
	let tableName: String
	let columns: [String]
	let rows: [TableRowData]
	let totalCount: Int
	let currentPage: Int
	let totalPages: Int
	let config: TableBrowserConfig

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

	public func render(indent: Int = 0) -> String {
		let tableColumns: [TableView.Column] = [
			TableView.Column(id: "#", label: "#", width: "50px")
		] + columns.map { column in
			TableView.Column(id: column, label: column)
		}

		let tableRows: [TableView.Row] = rows.enumerated().map { (index, row) in
			let rowId = row.cells[config.primaryKey] ?? "\(index)"
			var cells: [String: String] = ["#": "\((currentPage - 1) * 50 + index + 1)"]
			for column in columns {
				cells[column] = truncateValue(row.cells[column] ?? "")
			}
			return TableView.Row(id: rowId, cells: cells)
		}

		return section {
			// Header
			header {
				h1 { tableName }
				.style {
					fontFamily(typographyFontMono)
					fontSize(fontSizeXXLarge24)
					color(colorBase)
					margin(0)
				}

				p { "\(totalCount) rows" }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeSmall14)
					color(colorSubtle)
					margin(0)
				}
			}
			.class("table-browser-header")
			.style {
				display(.flex)
				flexDirection(.column)
				gap(spacing8)
				paddingBlockEnd(spacing24)
				borderBlockEnd(borderWidthBase, .solid, borderColorSubtle)
			}

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
						.style {
							fontSize(fontSizeSmall14)
							color(colorSubtle)
							fontFamily(typographyFontMono)
						}

						div {
							ButtonView(
								label: "Edit",
								buttonColor: .gray,
								weight: .subtle,
								size: .large,
								disabled: true,
								class: "action-edit"
							)

							ButtonView(
								label: "Delete",
								buttonColor: .gray,
								weight: .subtle,
								size: .large,
								disabled: true,
								class: "action-delete"
							)
						}
						.class("action-buttons")
						.style {
							display(.flex)
							gap(spacing8)
						}
					}
					.class("table-action-toolbar")
					.data("table", tableName)
					.data("base-url", config.baseURL)
					.data("primary-key", config.primaryKey)
					.style {
						display(.flex)
						justifyContent(.spaceBetween)
						alignItems(.center)
						width(perc(100))
					}
				}
			} emptyState: {
				div { "No data" }
				.style {
					fontSize(fontSizeLarge18)
					fontWeight(fontWeightSemiBold)
					marginBlockEnd(spacing8)
				}
				div { "This table has no rows" }
				.style {
					color(colorSubtle)
				}
			}

			// Pagination
			if totalPages > 1 {
				PaginationView(
					previousLabel: currentPage > 1 ? "\u{2190} Previous" : nil,
					previousUrl: currentPage > 1 ? "\(config.baseURL)/\(tableName)?page=\(currentPage - 1)" : nil,
					nextLabel: currentPage < totalPages ? "Next \u{2192}" : nil,
					nextUrl: currentPage < totalPages ? "\(config.baseURL)/\(tableName)?page=\(currentPage + 1)" : nil,
					pageNumbers: buildPageNumbers(),
					class: "table-browser-pagination"
				)
			}
		}
		.class("table-browser-container")
		.style {
			display(.flex)
			flexDirection(.column)
			gap(spacing24)
		}
		.render(indent: indent)
	}

	private func buildPageNumbers() -> [PaginationView.PageNumber] {
		var pages: [PaginationView.PageNumber] = []
		let baseUrl = "\(config.baseURL)/\(tableName)?page="

		// Show up to 7 page numbers with ellipsis-like windowing
		let windowSize = 2
		let start = max(1, currentPage - windowSize)
		let end = min(totalPages, currentPage + windowSize)

		if start > 1 {
			pages.append(PaginationView.PageNumber(label: "1", url: "\(baseUrl)1", isActive: currentPage == 1))
			if start > 2 {
				pages.append(PaginationView.PageNumber(label: "…", url: "", isActive: false))
			}
		}

		for p in start...end {
			pages.append(PaginationView.PageNumber(label: "\(p)", url: "\(baseUrl)\(p)", isActive: p == currentPage))
		}

		if end < totalPages {
			if end < totalPages - 1 {
				pages.append(PaginationView.PageNumber(label: "…", url: "", isActive: false))
			}
			pages.append(PaginationView.PageNumber(label: "\(totalPages)", url: "\(baseUrl)\(totalPages)", isActive: currentPage == totalPages))
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

#if os(WASI)

import WebAPIs
import EmbeddedSwiftUtilities

/// Hydration for TableBrowserView — extends TableView's built-in selection with
/// bulk action buttons, row click navigation, and selection count display.
public class TableBrowserHydration: @unchecked Sendable {
	private var selectionCountEl: Element?
	private var editButton: Element?
	private var deleteButton: Element?
	private var selectedRowIds: [String] = []
	private var tableName: String = ""
	private var baseURL: String = ""

	public init() {
		hydrate()
	}

	private func hydrate() {
		guard let tableView = document.querySelector(".table-browser-data") else { return }

		// Get config from toolbar data attributes
		if let toolbar = document.querySelector(".table-action-toolbar") {
			tableName = toolbar.getAttribute("data-table") ?? ""
			baseURL = toolbar.getAttribute("data-base-url") ?? ""
		}

		selectionCountEl = document.querySelector(".selection-count")
		editButton = document.querySelector(".action-edit")
		deleteButton = document.querySelector(".action-delete")

		// Listen for selection changes from TableView
		_ = tableView.addEventListener("table-selection-change") { [self] event in
			let detail = event.detail
			if detail.isEmpty {
				self.selectedRowIds = []
			} else {
				self.selectedRowIds = stringSplit(detail, separator: ",")
			}
			self.updateButtonStates()
		}

		// Edit button
		if let editBtn = editButton {
			_ = editBtn.addEventListener(.click) { [self] _ in
				guard self.selectedRowIds.count == 1, let rowId = self.selectedRowIds.first else { return }
				window.location.href = "\(self.baseURL)/\(self.tableName)/\(rowId)/edit"
			}
		}

		// Delete button
		if let deleteBtn = deleteButton {
			_ = deleteBtn.addEventListener(.click) { [self] _ in
				guard !self.selectedRowIds.isEmpty else { return }
				let count = self.selectedRowIds.count
				let message = count == 1
					? "Are you sure you want to delete this row?"
					: "Are you sure you want to delete \(count) rows?"
				if window.confirm(message) {
					let idsParam = stringJoin(self.selectedRowIds, separator: ",")
					window.location.href = "\(self.baseURL)/\(self.tableName)/delete?ids=\(idsParam)"
				}
			}
		}

		// Clickable rows — navigate to row detail view
		let rows = tableView.querySelectorAll(".table-row")
		for row in rows {
			row.style.cursor(.pointer)
			_ = row.addEventListener(.click) { [self] event in
				if let target = event.target {
					let tag = target.tagName
					if stringEquals(tag, "INPUT") || stringEquals(tag, "LABEL") {
						return
					}
				}
				if let rowId = row.getAttribute("data-row-id") {
					window.location.href = "\(self.baseURL)/\(self.tableName)/\(rowId)"
				}
			}
		}
	}

	private func updateButtonStates() {
		let count = selectedRowIds.count

		if let countEl = selectionCountEl {
			countEl.textContent = "\(count) selected"
		}

		editButton?.setDisabled(count != 1)
		deleteButton?.setDisabled(count == 0)
	}
}

#endif
