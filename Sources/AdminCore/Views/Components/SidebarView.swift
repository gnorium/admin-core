#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  public struct SidebarItem: Sendable {
    public let label: String
    public let url: String
    public let icon: (@Sendable (CSS.Length) -> [DOM.Node])?

    public init(label: String, url: String, icon: (@Sendable (CSS.Length) -> [DOM.Node])? = nil) {
      self.label = label
      self.url = url
      self.icon = icon
    }
  }

  public struct SidebarView: HTMLContent {
    let items: [SidebarItem]
    let bottomItems: [SidebarItem]
    let collapsed: Bool

    public init(items: [SidebarItem]? = nil, bottomItems: [SidebarItem]? = nil, collapsed: Bool = false) {
      self.items =
        items ?? [
          SidebarItem(label: "Dashboard", url: baseRoute),
          SidebarItem(label: "Users", url: "\(baseRoute)/users"),
          SidebarItem(label: "Database", url: "\(baseRoute)/database"),
          SidebarItem(label: "Invites", url: "\(baseRoute)/invites"),
          SidebarItem(label: "Security", url: "\(baseRoute)/mfa/setup"),
        ]
      self.bottomItems =
        bottomItems ?? [
          SidebarItem(
            label: "Back to site", url: "/",
            icon: { size in
              [PreviousIconView(width: size, height: size).build()]
            })
        ]
      self.collapsed = collapsed
    }

    public func build() -> DOM.Node {
      WebComponents.SidebarView(class: "sidebar-view", collapsed: collapsed) {
        div {
          nav {
            ul {
              // Section header
              li {
                h6 { "Admin Console" }
                  .class("sidebar-title")
                  .style {
                    fontSize(fontSizeXSmall12)
                    fontFamily(typographyFontSans)
                    fontWeight(fontWeightBold)
                    color(colorSubtle)
                    textTransform(.uppercase)
                    letterSpacing(em(0.05))
                  }
              }

              for item in items {
                renderItem(item)
              }

              if !bottomItems.isEmpty {
                li {}
                  .ariaHidden(true)
                  .style {
                    borderBlockStart(borderWidthBase, borderStyleBase, borderColorSubtle)
                  }
              }

              for item in bottomItems {
                renderItem(item, linkClass: "sidebar-link sidebar-back-link")
              }
            }
            .style {
              listStyle(.none)
              padding(0)
              margin(0)
              display(.flex)
              flexDirection(.column)
              gap(spacing16)

              descendant(".sidebar-back-link") {
                paddingInline(0).important()
              }
            }
          }
        }
        .style {
          padding(0)
        }
      }
    }

    @HTMLBuilder
    private func renderItem(_ item: SidebarItem, linkClass: String = "sidebar-link") -> [DOM.Node] {
      li {
        if let icon = item.icon {
          LinkView(url: item.url, weight: .plain, class: linkClass) {
            icon(px(20))
            span { item.label }
          }
        } else {
          LinkView(url: item.url, weight: .plain, class: linkClass) {
            item.label
          }
        }
      }
    }
  }
#endif
