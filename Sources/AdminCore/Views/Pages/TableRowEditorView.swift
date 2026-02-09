#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// View for editing a single table row
public struct TableRowEditorView: HTMLProtocol {
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
		section {
			// Header
			header {
				h1 { "Edit Row" }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeXXLarge24)
					color(colorBase)
					margin(0)
				}

				p { "Editing row \(rowId) in \(tableName)" }
				.style {
					fontFamily(typographyFontMono)
					fontSize(fontSizeSmall14)
					color(colorSubtle)
					margin(0)
				}
			}
			.class("table-editor-header")
			.style {
				display(.flex)
				flexDirection(.column)
				gap(spacing8)
				paddingBottom(spacing24)
				borderBottom(borderWidthBase, .solid, borderColorSubtle)
			}

			// Edit form
			form {
				// Hidden field for row ID
				input()
				.type(.hidden)
				.name("_id")
				.value(rowId)

				// System fields to hide from editing
				let systemFields = Set(["submission_schema_version", "content_hash", "created_at", "updated_at"])
				let editableColumns = columns.filter { !systemFields.contains($0) }

				// Fields for each column
				for column in editableColumns {
					div {
						label { column }
						.for("field-\(column)")
						.style {
							display(.block)
							fontFamily(typographyFontMono)
							fontSize(fontSizeSmall14)
							fontWeight(fontWeightSemiBold)
							color(colorBase)
							marginBottom(spacing8)
						}

						let value = rowData[column] ?? ""
						let isLongText = value.count > 100
						let isJSON = value.hasPrefix("[") || value.hasPrefix("{")

						if isLongText || isJSON {
							textarea { value }
							.id("field-\(column)")
							.name(column)
							.rows(isJSON ? 6 : 4)
							.style {
								width(perc(100))
								padding(spacing12)
								fontFamily(typographyFontSans)
								fontSize(fontSizeSmall14)
								color(colorBase)
								backgroundColor(backgroundColorBase)
								border(borderWidthBase, .solid, borderColorBase)
								borderRadius(borderRadiusBase)
								resize(.vertical)
							}
						} else {
							input()
							.type(.text)
							.id("field-\(column)")
							.name(column)
							.value(value)
							.style {
								width(perc(100))
								padding(spacing12)
								fontFamily(typographyFontSans)
								fontSize(fontSizeSmall14)
								color(colorBase)
								backgroundColor(backgroundColorBase)
								border(borderWidthBase, .solid, borderColorBase)
								borderRadius(borderRadiusBase)
							}
						}
					}
					.class("field-group")
					.style {
						display(.flex)
						flexDirection(.column)
					}
				}

				// Action buttons
				div {
					ButtonView(
						label: "Save Changes",
						buttonColor: .blue,
						weight: .solid,
						size: .large,
						type: .submit,
						class: "btn-save"
					)

					ButtonView(
						label: "Cancel",
						buttonColor: .gray,
						weight: .subtle,
						size: .large,
						url: "\(config.baseURL)/\(tableName)",
						class: "btn-cancel"
					)
				}
				.class("form-actions")
				.style {
					display(.flex)
					gap(spacing16)
					paddingTop(spacing24)
					borderTop(borderWidthBase, .solid, borderColorSubtle)
				}
			}
			.action("\(config.baseURL)/\(tableName)/\(rowId)")
			.method(.post)
			.class("table-editor-form")
			.style {
				display(.flex)
				flexDirection(.column)
				gap(spacing24)
			}
		}
		.class("table-editor-container")
		.style {
			display(.flex)
			flexDirection(.column)
			gap(spacing24)
			maxWidth(px(800))
		}
		.render(indent: indent)
	}
}

#endif
