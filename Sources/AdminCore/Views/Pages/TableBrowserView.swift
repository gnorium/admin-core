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
		section {
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
				paddingBottom(spacing24)
				borderBottom(borderWidthBase, .solid, borderColorSubtle)
			}

			// Action toolbar (hidden by default, shown when rows selected)
			if config.editable {
				div {
					div {
						span { "0 selected" }
						.class("selection-count")
						.style {
							fontSize(fontSizeSmall14)
							color(colorSubtle)
							fontFamily(typographyFontMono)
						}
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
					padding(spacing12, 0)
				}
			}

			// Table
			if rows.isEmpty {
				div {
					div { "No data" }
					.style {
						fontSize(fontSizeLarge18)
						fontWeight(fontWeightSemiBold)
						marginBottom(spacing8)
					}
					div { "This table has no rows" }
					.style {
						color(colorSubtle)
					}
				}
				.style {
					padding(spacing64)
					textAlign(.center)
					backgroundColor(backgroundColorBase)
					border(borderWidthBase, .solid, borderColorSubtle)
					borderRadius(borderRadiusBase)
				}
			} else {
				div {
					table {
						thead {
							tr {
								// Checkbox column header
								if config.editable {
									th {
										CheckboxView(
											id: "select-all",
											name: "select-all",
											class: "select-all-checkbox"
										) {
											[]  // No label
										}
									}
									.style {
										padding(spacing12, spacing16)
										textAlign(.center)
										borderBottom(borderWidthBase, .solid, borderColorSubtle)
										backgroundColor(backgroundColorNeutralSubtle)
										width(px(50))
									}
								}

								th { "#" }
								.style {
									padding(spacing12, spacing16)
									textAlign(.left)
									fontWeight(fontWeightSemiBold)
									fontSize(fontSizeSmall14)
									color(colorSubtle)
									borderBottom(borderWidthBase, .solid, borderColorSubtle)
									backgroundColor(backgroundColorNeutralSubtle)
									whiteSpace(.nowrap)
									width(px(50))
								}
								for column in columns {
									th { column }
									.style {
										padding(spacing12, spacing16)
										textAlign(.left)
										fontWeight(fontWeightSemiBold)
										fontSize(fontSizeSmall14)
										color(colorSubtle)
										borderBottom(borderWidthBase, .solid, borderColorSubtle)
										backgroundColor(backgroundColorNeutralSubtle)
										whiteSpace(.nowrap)
									}
								}
							}
						}
						tbody {
							for (index, row) in rows.enumerated() {
								let rowId = row.cells[config.primaryKey] ?? "\(index)"
								tr {
									// Checkbox column
									if config.editable {
										td {
											CheckboxView(
												id: "row-\(rowId)",
												name: "row-selection",
												value: rowId,
												class: "row-checkbox"
											) {
												[]  // No label
											}
										}
										.data("row-id", rowId)
										.style {
											padding(spacing12, spacing16)
											textAlign(.center)
											borderBottom(borderWidthBase, .solid, borderColorSubtle)
										}
									}

									td { "\((currentPage - 1) * 50 + index + 1)" }
									.style {
										padding(spacing12, spacing16)
										borderBottom(borderWidthBase, .solid, borderColorSubtle)
										fontSize(fontSizeSmall14)
										color(colorSubtle)
										fontFamily(typographyFontMono)
										whiteSpace(.nowrap)
									}
									for column in columns {
										td { truncateValue(row.cells[column] ?? "") }
										.title(row.cells[column] ?? "")
										.style {
											padding(spacing12, spacing16)
											borderBottom(borderWidthBase, .solid, borderColorSubtle)
											fontSize(fontSizeSmall14)
											fontFamily(typographyFontMono)
											maxWidth(px(300))
											overflow(.hidden)
											textOverflow(.ellipsis)
											whiteSpace(.nowrap)
										}
									}
								}
								.class("table-row")
								.data("row-id", rowId)
								.style {
									transition("background-color 0.1s ease")
								}
							}
						}
					}
					.class("table-browser-data")
					.style {
						width(perc(100))
						borderCollapse(.collapse)
						backgroundColor(backgroundColorBase)
					}
				}
				.class("table-browser-table")
				.style {
					overflowX(.auto)
					border(borderWidthBase, .solid, borderColorSubtle)
					borderRadius(borderRadiusBase)
				}
			}

			// Pagination
			if totalPages > 1 {
				PaginationView(
					previousLabel: currentPage > 1 ? "\u{2190} Previous" : nil,
					previousHref: currentPage > 1 ? "\(config.baseURL)/\(tableName)?page=\(currentPage - 1)" : nil,
					nextLabel: currentPage < totalPages ? "Next \u{2192}" : nil,
					nextHref: currentPage < totalPages ? "\(config.baseURL)/\(tableName)?page=\(currentPage + 1)" : nil,
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
		let baseHref = "\(config.baseURL)/\(tableName)?page="

		// Show up to 7 page numbers with ellipsis-like windowing
		let windowSize = 2
		let start = max(1, currentPage - windowSize)
		let end = min(totalPages, currentPage + windowSize)

		if start > 1 {
			pages.append(PaginationView.PageNumber(label: "1", href: "\(baseHref)1", isActive: currentPage == 1))
			if start > 2 {
				pages.append(PaginationView.PageNumber(label: "…", href: "", isActive: false))
			}
		}

		for p in start...end {
			pages.append(PaginationView.PageNumber(label: "\(p)", href: "\(baseHref)\(p)", isActive: p == currentPage))
		}

		if end < totalPages {
			if end < totalPages - 1 {
				pages.append(PaginationView.PageNumber(label: "…", href: "", isActive: false))
			}
			pages.append(PaginationView.PageNumber(label: "\(totalPages)", href: "\(baseHref)\(totalPages)", isActive: currentPage == totalPages))
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
import DesignTokens
import WebTypes
import EmbeddedSwiftUtilities

private class TableBrowserInstance: @unchecked Sendable {
	private var container: Element
	private var selectAllCheckbox: Element?
	private var rowCheckboxes: [Element] = []
	private var selectionCountEl: Element?
	private var editButton: Element?
	private var deleteButton: Element?
	private var selectedRowIds: [String] = []
	private var tableName: String = ""
	private var baseURL: String = ""
	private var primaryKey: String = "id"

	init(container: Element) {
		self.container = container

		// Get config from data attributes
		if let toolbar = container.querySelector(".table-action-toolbar") {
			tableName = toolbar.getAttribute("data-table") ?? ""
			baseURL = toolbar.getAttribute("data-base-url") ?? ""
			primaryKey = toolbar.getAttribute("data-primary-key") ?? "id"
		}

		selectAllCheckbox = container.querySelector(".select-all-checkbox .checkbox-input")
		rowCheckboxes = Array(container.querySelectorAll(".row-checkbox .checkbox-input"))
		selectionCountEl = container.querySelector(".selection-count")
		editButton = container.querySelector(".action-edit")
		deleteButton = container.querySelector(".action-delete")

		bindEvents()
	}

	private func bindEvents() {
		// Select all checkbox
		if let selectAll = selectAllCheckbox {
			_ = selectAll.addEventListener(.change) { [self] _ in
				self.toggleSelectAll()
			}
		}

		// Row checkboxes
		for checkbox in rowCheckboxes {
			_ = checkbox.addEventListener(.change) { [self] _ in
				self.updateSelection()
			}
		}

		// Edit button
		if let editBtn = editButton {
			_ = editBtn.addEventListener(.click) { [self] _ in
				self.handleEdit()
			}
		}

		// Delete button
		if let deleteBtn = deleteButton {
			_ = deleteBtn.addEventListener(.click) { [self] _ in
				self.handleDelete()
			}
		}

		// Clickable rows — navigate to row detail view
		let rows = container.querySelectorAll(".table-row")
		for row in rows {
			row.style.cursor(.pointer)

			_ = row.addEventListener(.mouseenter) { _ in
				row.style.setProperty("background-color", "var(--background-color-neutral-subtle)")
			}
			_ = row.addEventListener(.mouseleave) { [self] _ in
				// Restore: check if row is selected (has highlight)
				var isSelected = false
				if let rowId = row.getAttribute("data-row-id") {
					for id in self.selectedRowIds {
						if stringEquals(id, rowId) {
							isSelected = true
							break
						}
					}
				}
				row.style.setProperty("background-color", isSelected ? "var(--background-color-progressive-subtle)" : "")
			}

			_ = row.addEventListener(.click) { [self] event in
				// Don't navigate if clicking on checkbox or its label
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

	private func toggleSelectAll() {
		guard let selectAll = selectAllCheckbox else { return }
		let isChecked = selectAll.checked

		for checkbox in rowCheckboxes {
			checkbox.checked = isChecked
		}

		updateSelection()
	}

	private func updateSelection() {
		selectedRowIds = []

		for checkbox in rowCheckboxes {
			if checkbox.checked {
				// Get row ID from checkbox value (set in CheckboxView)
				let rowId = checkbox.getValue()
				if !rowId.isEmpty {
					selectedRowIds.append(rowId)
				}
			}
		}

		// Update select all checkbox state
		if let selectAll = selectAllCheckbox {
			if selectedRowIds.isEmpty {
				selectAll.checked = false
				selectAll.indeterminate = false
			} else if selectedRowIds.count == rowCheckboxes.count {
				selectAll.checked = true
				selectAll.indeterminate = false
			} else {
				selectAll.checked = false
				selectAll.indeterminate = true
			}
		}

		// Update selection count
		if let countEl = selectionCountEl {
			countEl.textContent = "\(selectedRowIds.count) selected"
		}

		// Update button states
		let hasSelection = !selectedRowIds.isEmpty
		let singleSelection = selectedRowIds.count == 1

		if let editBtn = editButton {
			editBtn.disabled = !singleSelection
		}

		if let deleteBtn = deleteButton {
			deleteBtn.disabled = !hasSelection
		}

		// Highlight selected rows
		let allRows = container.querySelectorAll(".table-row")
		for row in allRows {
			if let rowId = row.getAttribute("data-row-id") {
				var isSelected = false
				for id in selectedRowIds {
					if stringEquals(id, rowId) {
						isSelected = true
						break
					}
				}
				row.style.setProperty("background-color", isSelected ? "var(--background-color-progressive-subtle)" : "")
			}
		}
	}

	private func handleEdit() {
		guard selectedRowIds.count == 1, let rowId = selectedRowIds.first else { return }
		// Navigate to edit page
		window.location.href = "\(baseURL)/\(tableName)/\(rowId)/edit"
	}

	private func handleDelete() {
		guard !selectedRowIds.isEmpty else { return }

		let count = selectedRowIds.count
		let message = count == 1
			? "Are you sure you want to delete this row?"
			: "Are you sure you want to delete \(count) rows?"

		if window.confirm(message) {
			// Build comma-separated IDs
			var joinedIds: [UInt8] = []
			for (index, id) in selectedRowIds.enumerated() {
				if index > 0 {
					joinedIds.append(44) // comma
				}
				joinedIds.append(contentsOf: id.utf8)
			}
			let idsParam = String(decoding: joinedIds, as: UTF8.self)

			// Navigate to delete endpoint (will be handled as POST via form on the page)
			window.location.href = "\(baseURL)/\(tableName)/delete?ids=\(idsParam)"
		}
	}
}

public class TableBrowserHydration: @unchecked Sendable {
	private var instances: [TableBrowserInstance] = []

	public init() {
		hydrateAll()
	}

	private func hydrateAll() {
		let containers = document.querySelectorAll(".table-browser-container")
		for container in containers {
			let instance = TableBrowserInstance(container: container)
			instances.append(instance)
		}
	}
}

#endif
