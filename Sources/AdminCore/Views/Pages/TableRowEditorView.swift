#if SERVER

import CSSBuilder
import DesignTokens
import DOMBuilder
import HTMLBuilder
import WebComponents
import WebTypes

public struct TableRowEditorView: HTMLContent {
	let tableName: String
	let data: FormData
	let columns: [String]
	let admin: AnyModelAdmin?
	let config: TableBrowserConfig

	public init(
		tableName: String,
		data: FormData,
		columns: [String] = [],
		admin: AnyModelAdmin? = nil,
		config: TableBrowserConfig = TableBrowserConfig()
	) {
		self.tableName = tableName
		self.data = data
		self.columns = columns
		self.admin = admin
		self.config = config
	}

	public func render() -> DOMNode {
		let rowID = data.id ?? ""
		
		return section {
			// Header
			header {
				h1 { "Edit Row" }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeXXLarge24)
					fontWeight(fontWeightSemiBold)
					color(colorBase)
					margin(0)
				}

				p { "Editing row \(rowID) in \(tableName)" }
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
				.value(rowID)

				// Fields
				if let admin = admin {
					// Managed mode — use FieldConfig but keep it simple
					for field in admin.editFields {
						renderFieldGroup(labelText: field.label, name: field.name, value: data.values[field.name] ?? field.defaultValue ?? "")
					}
				} else {
					// Raw mode — loop through columns
					let systemFields = Set(["submission_schema_version", "content_hash", "created_at", "updated_at"])
					let editableColumns = columns.filter { !systemFields.contains($0) }

					for column in editableColumns {
						renderFieldGroup(labelText: column, name: column, value: data.values[column] ?? "")
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
						url: "\(config.baseURL)/\(tableName)/\(rowID)",
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
			.action("\(config.baseURL)/\(tableName)/\(rowID)")
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
			maxWidth(px(1000))
			margin(0, .auto)
			padding(spacing48, spacing24)
		}
		.render()
	}

	@HTMLBuilder
	private func renderFieldGroup(labelText: String, name: String, value: String) -> [DOMNode] {
		div {
			label { labelText }
			.for("field-\(name)")
			.style {
				display(.block)
				fontFamily(typographyFontSans)
				fontSize(fontSizeSmall14)
				fontWeight(fontWeightSemiBold)
				color(colorBase)
				marginBottom(spacing8)
			}

			let isLongText = value.count > 100 || name == "content" || name == "description"
			let isJSON = value.hasPrefix("[") || value.hasPrefix("{")

			if isLongText || isJSON {
				TextAreaView(
					id: "field-\(name)",
					name: name,
					placeholder: "Enter \(labelText.lowercased())...",
					value: value,
					rows: isJSON ? 8 : 12,
					autosize: true,
					class: "field-input"
				)
			} else {
				TextInputView(
					id: "field-\(name)",
					name: name,
					placeholder: "Enter \(labelText.lowercased())...",
					value: value,
					class: "field-input"
				)
			}
		}
		.class("field-group")
	}
}

#endif
