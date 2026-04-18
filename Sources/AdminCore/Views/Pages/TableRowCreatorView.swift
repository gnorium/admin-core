#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// View for creating a new database table row
public struct TableRowCreatorView: HTMLContent {
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

	public func render(indent: Int = 0) -> String {
		section {
			// Header
			header {
				h1 { "New Row" }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeXXLarge24)
					fontWeight(fontWeightSemiBold)
					color(colorBase)
					margin(0)
				}

				p { "Creating a new row in \(tableName)" }
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

			// Creation form
			form {
				// Fields
				if let admin = admin {
					// Managed mode — use FieldConfig but keep it simple
					for field in admin.editFields {
						renderFieldGroup(labelText: field.label, name: field.name, value: data.values[field.name] ?? field.defaultValue ?? "")
					}
				} else {
					// Raw mode — loop through columns
					let systemFields = Set(["id", "submission_schema_version", "content_hash", "created_at", "updated_at"])
					let editableColumns = columns.filter { !systemFields.contains($0) }

					for column in editableColumns {
						renderFieldGroup(labelText: column, name: column, value: data.values[column] ?? "")
					}
				}

				// Action buttons
				div {
					ButtonView(
						label: "Create",
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
			.action("\(config.baseURL)/\(tableName)")
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
		.render(indent: indent)
	}

	@HTMLBuilder
	private func renderFieldGroup(labelText: String, name: String, value: String) -> [AnyHTMLContent] {
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

			let isLongText = name == "content" || name == "description"
			
			if isLongText {
				TextAreaView(
					id: "field-\(name)",
					name: name,
					placeholder: "Enter \(labelText.lowercased())...",
					value: value,
					rows: 12,
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
