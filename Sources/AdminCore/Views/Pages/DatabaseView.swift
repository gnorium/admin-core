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

  /// Database explorer: grid of tables with navigation into ``TableBrowserView``.
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
        // Header
        header {
          h1 { config.title }
            .class("database-title")

          p { config.subtitle }
            .class("database-subtitle")
        }
        .class("database-header")

        // Stats row
        div {
          renderStatBadge("Tables", tables.count)
        }
        .class("database-stats")

        // Table grid
        div {
          for (index, table) in tables.enumerated() {
            a {
              div {
                div {
                  span { "\(index + 1)" }
                    .class("database-table-index")
                  span { table.name }
                    .class("database-table-name")
                  span { "(\(table.rowCount))" }
                    .class("database-table-count")
                }
                .class("database-table-summary")

                span { "\u{2192}" }
                  .class("database-table-arrow")
              }
              .class("database-table-card")
            }
            .href("\(config.baseURL)/\(table.name)")
            .class("database-table-link")
          }
        }
        .class("tables-grid")
      }
      .class("database-container")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing32)
        }
        descendant(".database-header") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
          paddingBottom(spacing32)
          borderBottom(borderWidthBase, .solid, borderColorSubtle)
        }
        descendant(".database-title") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeXXXLarge28)
          color(colorBase)
          margin(0)
        }
        descendant(".database-subtitle") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          margin(0)
        }
        descendant(".database-stats") {
          display(.flex)
          gap(spacing16)
        }
        descendant(".tables-grid") {
          display(.grid)
          gridTemplateColumns("1fr")
          gap(spacing16)
        }
        descendant(".database-table-link") {
          textDecoration(.none)
          display(.block)
        }
        descendant(".database-table-card") {
          display(.flex)
          justifyContent(.spaceBetween)
          alignItems(.center)
          padding(spacing16, spacing20)
          backgroundColor(backgroundColorBase)
          border(borderWidthBase, .solid, borderColorSubtle)
          borderRadius(borderRadiusBase)
          color(colorBase)
          textDecoration(.none)
          transition("all 0.15s ease")
        }
        descendant(".database-table-summary") {
          display(.flex)
          alignItems(.center)
          gap(spacing12)
        }
        descendant(".database-table-index") {
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          fontFamily(typographyFontMono)
          minWidth(px(24))
        }
        descendant(".database-table-name") {
          fontWeight(fontWeightNormal)
          fontSize(fontSizeMedium16)
        }
        descendant(".database-table-count") {
          fontWeight(fontWeightNormal)
          fontSize(fontSizeMedium16)
          color(colorSubtle)
        }
        descendant(".database-table-arrow") {
          color(colorSubtle)
          fontSize(fontSizeMedium16)
          fontFamily(typographyFontMono)
        }
        descendant(".database-stat") {
          padding(spacing16, spacing24)
          backgroundColor(backgroundColorBase)
          border(borderWidthBase, .solid, borderColorSubtle)
          borderRadius(borderRadiusBase)
        }
        descendant(".database-stat-label") {
          fontSize(fontSizeXSmall12)
          color(colorSubtle)
          textTransform(.uppercase)
          letterSpacing(px(0.5))
          fontWeight(fontWeightBold)
        }
        descendant(".database-stat-value") {
          fontSize(fontSizeMedium16)
          color(colorBase)
          fontFamily(typographyFontSans)
          fontWeight(fontWeightNormal)
        }
      }
    }

    @HTMLBuilder
    private func renderStatBadge(_ label: String, _ value: Int) -> [DOM.Node] {
      div {
        span { label }
          .class("database-stat-label")
        div { "\(value)" }
          .class("database-stat-value")
      }
      .class("database-stat")
    }
  }
#endif
