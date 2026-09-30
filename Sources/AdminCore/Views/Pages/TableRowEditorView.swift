#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// Edit form for an existing database table row.
  public struct TableRowEditorView: HTMLContent {
    let tableName: String
    let data: FormData
    let columns: [String]
    let admin: AnyModelAdmin?
    let config: TableBrowserConfig

    /// - Parameters:
    ///   - tableName: Database table name (display and form routing).
    ///   - data: Current field values (must include id when editing).
    ///   - columns: Column names when not using a ``ModelAdmin``.
    ///   - admin: Optional model admin for richer field configs.
    ///   - config: Browser URLs and primary key settings.
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

    /// Builds an editor from a flat column → value map.
    public init(
      tableName: String,
      columns: [String],
      rowData: [String: String],
      rowID: String,
      config: TableBrowserConfig = TableBrowserConfig()
    ) {
      self.tableName = tableName
      self.data = FormData(id: rowID, values: rowData)
      self.columns = columns
      self.admin = nil
      self.config = config
    }

    public func build() -> DOM.Node {
      let rowID = data.id ?? ""

      return section {
        // Header
        header {
          h1 { "Edit Row" }
            .class("table-editor-title")

          p { "Editing row \(rowID) in \(tableName)" }
            .class("table-editor-subtitle")
        }
        .class("table-editor-header")

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
              renderFieldGroup(
                labelText: field.label, name: field.name,
                value: data.values[field.name] ?? field.defaultValue ?? "")
            }
          } else {
            // Raw mode — loop through columns
            let systemFields = Set([
              "submission_schema_version", "content_hash", "created_at", "updated_at",
            ])
            let editableColumns = columns.filter { !systemFields.contains($0) }

            for column in editableColumns {
              renderFieldGroup(labelText: column, name: column, value: data.values[column] ?? "")
            }
          }

          // Action buttons
          ButtonGroupView(
            buttons: [
              .init(
                value: "save", label: "Save Changes",
                buttonColor: .blue, weight: .solid, type: .submit, class: "btn-save"
              ),
              .init(
                value: "cancel", label: "Cancel",
                url: config.backURL, class: "btn-cancel"
              ),
            ],
            class: "form-actions"
          )
        }
        .action("\(config.baseURL)/\(tableName)/\(rowID)")
        .method(.post)
        .class("table-editor-form")
      }
      .class("table-row-editor-view")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
          maxWidth(px(1000))
          marginInline(.auto)
        }
        descendant(".table-editor-header") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
          paddingBlockEnd(spacing24)
          borderBlockEnd(borderWidthBase, .solid, borderColorSubtle)
        }
        descendant(".table-editor-title") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeXXLarge24)
          fontWeight(fontWeightSemiBold)
          color(colorBase)
          margin(0)
        }
        descendant(".table-editor-subtitle") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          margin(0)
        }
        descendant(".table-editor-form") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
        }
        descendant(".form-actions") {
          width(perc(100))
          gap(spacing16)
          paddingBlockStart(spacing24)
          borderBlockStart(borderWidthBase, .solid, borderColorSubtle)
        }
      }
    }

    /// One column's field: its name as the label (and the placeholder); a
    /// long or JSON value in a text area.
    @HTMLBuilder
    private func renderFieldGroup(labelText: String, name: String, value: String) -> [DOM.Node] {
      let isLongText = value.count > 100 || name == "content" || name == "description"
      let isJSON = value.hasPrefix("[") || value.hasPrefix("{")
      FieldView(id: "field-\(name)") {
        labelText
      } input: {
        if isLongText || isJSON {
          TextAreaView(
            id: "field-\(name)",
            name: name,
            placeholder: labelText,
            value: value,
            rows: isJSON ? 8 : 12,
            autosize: true
          )
        } else {
          TextInputView(
            id: "field-\(name)",
            name: name,
            placeholder: labelText,
            value: value
          )
        }
      }
    }
  }
#endif
