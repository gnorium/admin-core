#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// Title and routing options for ``DatabaseView``.
  public struct DatabaseViewConfig: Sendable {
    /// Page title.
    public let title: String
    /// Supporting subtitle.
    public let subtitle: String
    /// Base URL for table links.
    public let baseURL: String

    /// Creates database explorer configuration.
    public init(
      title: String = "Database",
      subtitle: String = "Direct access to database tables. Use with caution.",
      baseURL: String = "/admin-console/database"
    ) {
      self.title = title
      self.subtitle = subtitle
      self.baseURL = baseURL
    }
  }

  /// Summary of one database table for the explorer grid.
  public struct TableDisplayInfo: Sendable {
    /// Table name.
    public let name: String
    /// Approximate or exact row count.
    public let rowCount: Int

    /// Creates a table summary.
    public init(name: String, rowCount: Int) {
      self.name = name
      self.rowCount = rowCount
    }
  }

  /// Database explorer: every table, numbered, with its row count, each
  /// linking to its ``TableBrowserView``.
  public struct DatabaseView: HTMLContent {
    let tables: [TableDisplayInfo]
    let config: DatabaseViewConfig

    /// - Parameters:
    ///   - tables: Tables to list.
    ///   - config: Page title and base URL.
    public init(
      tables: [TableDisplayInfo],
      config: DatabaseViewConfig = DatabaseViewConfig()
    ) {
      self.tables = tables
      self.config = config
    }

    public func build() -> DOM.Node {
      section {
        header {
          h1 { config.title }
            .class("database-title")

          p { config.subtitle }
            .class("database-subtitle")
        }
        .class("database-header")

        TableView(
          captionContent: "Tables",
          hideCaption: true,
          columns: [
            TableView.Column(id: "index", label: "#", align: .number, width: px(56)),
            TableView.Column(id: "table", label: "Table", priority: true),
            TableView.Column(id: "rows", label: "Rows", align: .number, width: px(120)),
          ],
          data: tables.enumerated().map { index, table in
            TableView.Row(
              id: table.name,
              cells: [
                "index": DOM.Text("\(index + 1)"),
                "table": LinkView(url: "\(config.baseURL)/\(table.name)") { table.name }.build(),
                "rows": DOM.Text("\(table.rowCount)"),
              ])
          },
          class: "database-tables",
          emptyState: {
            span { "No tables." }
              .class("database-empty")
          }
        )
      }
      .class("database-view")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
          minWidth(0)
        }
        descendant(".database-header") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
          paddingBlockEnd(spacing24)
          borderBlockEnd(borderWidthBase, .solid, borderColorBase)
        }
        descendant(".database-title") {
          margin(0)
          fontFamily(typographyFontSans)
          fontSize(fontSizeXXXLarge28)
          fontWeight(fontWeightNormal)
          color(colorBase)
        }
        descendant(".database-subtitle") {
          margin(0)
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          color(colorSubtle)
        }
        descendant(".database-empty") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          color(colorSubtle)
        }
      }
    }
  }
#endif
