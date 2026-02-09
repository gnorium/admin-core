#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Read-only detail view for a single database table row
public struct TableRowDetailsView: HTMLProtocol {
	let tableName: String
	let columns: [String]
	let rowData: [String: String]
	let rowId: String
	let config: TableBrowserConfig

	public init(
		tableName: String,
		columns: [String],
		rowData: [String: String],
		rowId: String,
		config: TableBrowserConfig = TableBrowserConfig()
	) {
		self.tableName = tableName
		self.columns = columns
		self.rowData = rowData
		self.rowId = rowId
		self.config = config
	}

	public func render(indent: Int = 0) -> String {
		return section {
			// Header
			header {
				div {
					h1 { tableName }
					.style {
						fontFamily(typographyFontMono)
						fontSize(fontSizeXXLarge24)
						color(colorBase)
						margin(0)
					}

					p { "Row \(rowId)" }
					.style {
						fontFamily(typographyFontMono)
						fontSize(fontSizeSmall14)
						color(colorSubtle)
						margin(0)
					}
				}
				.style {
					display(.flex)
					flexDirection(.column)
					gap(spacing4)
				}

				// Action buttons
				div {
					ButtonView(
						label: "Edit",
						buttonColor: .gray,
						weight: .subtle,
						size: .large,
						url: "\(config.baseURL)/\(tableName)/\(rowId)/edit",
						class: "btn-edit-row"
					)

					ButtonView(
						label: "Delete",
						buttonColor: .gray,
						weight: .subtle,
						size: .large,
						class: "btn-delete-row"
					)
				}
				.class("row-detail-actions")
				.data("table", tableName)
				.data("row-id", rowId)
				.data("base-url", config.baseURL)
				.style {
					display(.flex)
					gap(spacing8)
				}
			}
			.style {
				display(.flex)
				justifyContent(.spaceBetween)
				alignItems(.flexStart)
				paddingBlockEnd(spacing24)
				borderBlockEnd(borderWidthBase, .solid, borderColorSubtle)
			}

			// Field list
			div {
				for column in columns {
					let value = rowData[column] ?? ""
					let isLong = value.count > 100
					let isJSON = value.hasPrefix("[") || value.hasPrefix("{")

					div {
						div { column }
						.style {
							fontFamily(typographyFontMono)
							fontSize(fontSizeXSmall12)
							fontWeight(fontWeightSemiBold)
							color(colorSubtle)
							textTransform(.uppercase)
							letterSpacing(px(0.5))
						}

						if value.isEmpty {
							span { "NULL" }
							.style {
								fontFamily(typographyFontMono)
								fontSize(fontSizeSmall14)
								color(colorSubtle)
								fontStyle(.italic)
							}
						} else if isLong || isJSON {
							pre { value }
							.style {
								margin(0)
								padding(spacing12)
								backgroundColor(backgroundColorNeutralSubtle)
								border(borderWidthBase, .solid, borderColorSubtle)
								borderRadius(borderRadiusBase)
								fontFamily(typographyFontMono)
								fontSize(fontSizeSmall14)
								lineHeight(1.6)
								whiteSpace(.preWrap)
								wordBreak(.breakAll)
								maxHeight(px(400))
								overflow(.auto)
							}
						} else {
							span { value }
							.style {
								fontFamily(typographyFontMono)
								fontSize(fontSizeSmall14)
								color(colorBase)
							}
						}
					}
					.style {
						display(.flex)
						flexDirection(.column)
						gap(spacing8)
						paddingBlock(spacing16)
						borderBlockEnd(borderWidthBase, .solid, borderColorSubtle)
					}
				}
			}
			.class("row-detail-fields")
			.style {
				display(.flex)
				flexDirection(.column)
			}
		}
		.class("table-row-detail-container")
		.data("hydrate", "table-row-detail")
		.style {
			display(.flex)
			flexDirection(.column)
			gap(spacing24)
		}
		.render(indent: indent)
	}
}

#endif

#if os(WASI)

import WebAPIs
import DesignTokens
import WebTypes
import EmbeddedSwiftUtilities

private class TableRowDetailInstance: @unchecked Sendable {
	private var container: Element
	private var tableName: String = ""
	private var rowId: String = ""
	private var baseURL: String = ""

	init(container: Element) {
		self.container = container

		if let actions = container.querySelector(".row-detail-actions") {
			tableName = actions.getAttribute("data-table") ?? ""
			rowId = actions.getAttribute("data-row-id") ?? ""
			baseURL = actions.getAttribute("data-base-url") ?? ""
		}

		bindEvents()
	}

	private func bindEvents() {
		if let deleteBtn = container.querySelector(".btn-delete-row") {
			_ = deleteBtn.addEventListener(.click) { [self] _ in
				if window.confirm("Are you sure you want to delete this row?") {
					window.location.href = "\(self.baseURL)/\(self.tableName)/delete?ids=\(self.rowId)"
				}
			}
		}
	}
}

public class TableRowDetailHydration: @unchecked Sendable {
	private var instances: [TableRowDetailInstance] = []

	public init() {
		hydrateAll()
	}

	private func hydrateAll() {
		let containers = document.querySelectorAll(".table-row-detail-container")
		for container in containers {
			let instance = TableRowDetailInstance(container: container)
			instances.append(instance)
		}
	}
}

#endif
