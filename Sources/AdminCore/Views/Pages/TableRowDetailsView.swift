#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// Read-only detail page for a single database table row.
  public struct TableRowDetailsView: HTMLContent {
    let tableName: String
    let columns: [String]
    let rowData: [String: String]
    let rowID: String
    let config: TableBrowserConfig

    /// - Parameters:
    ///   - tableName: Table name shown in the header.
    ///   - columns: Column order for display.
    ///   - rowData: Column → value map.
    ///   - rowID: Primary key value for this row.
    ///   - config: Browser URLs and editability.
    public init(
      tableName: String,
      columns: [String],
      rowData: [String: String],
      rowID: String,
      config: TableBrowserConfig = TableBrowserConfig()
    ) {
      self.tableName = tableName
      self.columns = columns
      self.rowData = rowData
      self.rowID = rowID
      self.config = config
    }

    public func build() -> DOM.Node {
      return section {
        // Header
        header {
          div {
            h1 { tableName }
              .class("row-detail-title")

            p { "Row \(rowID)" }
              .class("row-detail-subtitle")
          }
          .class("row-detail-heading")

          // Action buttons
          div {
            ButtonView(
              label: "Edit",
              buttonColor: .gray,
              weight: .subtle,
              size: .medium,
              url: "\(config.baseURL)/\(tableName)/\(rowID)/edit",
              class: "btn-edit-row"
            )

            ButtonView(
              label: "Delete",
              buttonColor: .gray,
              weight: .subtle,
              size: .medium,
              class: "btn-delete-row"
            )
          }
          .class("row-detail-actions")
          .data("table", tableName)
          .data("row-id", rowID)
          .data("base-url", config.baseURL)
        }
        .class("row-detail-header")

        // Field list
        div {
          for column in columns {
            let value = rowData[column] ?? ""
            let isLong = value.count > 100
            let isJSON = value.hasPrefix("[") || value.hasPrefix("{")

            div {
              div { column }
                .class("row-detail-field-label")

              if value.isEmpty {
                span { "NULL" }
                  .class("row-detail-null")
              } else if isLong || isJSON {
                pre { value }
                  .class("row-detail-code")
              } else {
                span { value }
                  .class("row-detail-value")
              }
            }
            .class("row-detail-field")
          }
        }
        .class("row-detail-fields")
      }
      .class("table-row-detail-view")
      .data("hydrate", "table-row-detail")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
        }
        descendant(".row-detail-header") {
          display(.flex)
          justifyContent(.spaceBetween)
          alignItems(.flexStart)
          paddingBlockEnd(spacing24)
          borderBlockEnd(borderWidthBase, .solid, borderColorSubtle)
        }
        descendant(".row-detail-heading") {
          display(.flex)
          flexDirection(.column)
          gap(spacing4)
        }
        descendant(".row-detail-title") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeXXLarge24)
          color(colorBase)
          margin(0)
        }
        descendant(".row-detail-subtitle") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          margin(0)
        }
        descendant(".row-detail-actions") {
          display(.flex)
          gap(spacing8)
        }
        descendant(".row-detail-fields") {
          display(.flex)
          flexDirection(.column)
        }
        descendant(".row-detail-field") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
          paddingBlock(spacing16)
          borderBlockEnd(borderWidthBase, .solid, borderColorSubtle)
        }
        descendant(".row-detail-field-label") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeXSmall12)
          fontWeight(fontWeightSemiBold)
          color(colorSubtle)
          textTransform(.uppercase)
          letterSpacing(px(0.5))
        }
        descendant(".row-detail-null") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          fontStyle(.italic)
        }
        descendant(".row-detail-value") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeSmall14)
          color(colorBase)
        }
        descendant(".row-detail-code") {
          margin(0)
          padding(spacing12)
          backgroundColor(backgroundColorNeutralSubtle)
          border(borderWidthBase, .solid, borderColorSubtle)
          borderRadius(borderRadiusBase)
          fontFamily(typographyFontMono)
          fontSize(fontSizeSmall14)
          lineHeight(1.618)
          whiteSpace(.preWrap)
          wordBreak(.breakAll)
          maxHeight(px(400))
          overflow(.auto)
        }
      }
    }
  }
#endif

#if CLIENT
  import DOMBuilder
  import EmbeddedSwiftUtilities
  import HTMLBuilder
  import WebAPIs
  import WebTypes

  private class TableRowDetailInstance: @unchecked Sendable {
    private var container: DOM.Element
    private var tableName: String = ""
    private var rowID: String = ""
    private var baseURL: String = ""

    init(container: DOM.Element) {
      self.container = container

      if let actions = container.querySelector(".row-detail-actions") {
        tableName = actions.getAttribute(data("table")) ?? ""
        rowID = actions.getAttribute(data("row-id")) ?? ""
        baseURL = actions.getAttribute(data("base-url")) ?? ""
      }

      bindEvents()
    }

    private func bindEvents() {
      if let deleteBtn = container.querySelector(".btn-delete-row") {
        _ = deleteBtn.addEventListener(.click) { [self] (event: Event) in
          if window.confirm("Are you sure you want to delete this row?") {
            window.location.href = "\(self.baseURL)/\(self.tableName)/delete?ids=\(self.rowID)"
          }
        }
      }
    }
  }

  /// Client hydration for ``TableRowDetailsView`` (e.g. copy / delete affordances).
  public class TableRowDetailHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: TableRowDetailHydration?
    private var instances: [TableRowDetailInstance] = []

    public init() {
      hydrateAll()
    }

    public static func hydrateIfPresent() {
      guard document.querySelector(".table-row-detail-view") != nil else { return }
      instance = TableRowDetailHydration()
    }

    private func hydrateAll() {
      let containers = document.querySelectorAll(".table-row-detail-view")
      for container in containers {
        let instance = TableRowDetailInstance(container: container)
        instances.append(instance)
      }
    }
  }
#endif
