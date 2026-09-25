#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// One navigation entry in ``SidebarView``.
  public struct SidebarItem: Sendable {
    /// Visible label.
    public let label: String
    /// Navigation URL.
    public let url: String
    /// Optional icon builder given a size token.
    public let icon: (@Sendable (CSS.Length) -> [DOM.Node])?

    /// Creates a sidebar item.
    public init(label: String, url: String, icon: (@Sendable (CSS.Length) -> [DOM.Node])? = nil) {
      self.label = label
      self.url = url
      self.icon = icon
    }
  }

  /// Left sidebar navigation for the admin console.
  ///
  /// When `items` / `bottomItems` are omitted, a default set of admin destinations is used
  /// (dashboard, users, database, invites, MFA setup, back to site).
  public struct SidebarView: HTMLContent {
    let items: [SidebarItem]
    let bottomItems: [SidebarItem]
    let collapsed: Bool

    /// Creates a sidebar.
    /// - Parameters:
    ///   - items: Primary nav items; `nil` uses built-in defaults.
    ///   - bottomItems: Footer nav items; `nil` uses “Back to site”.
    ///   - collapsed: Whether the sidebar starts collapsed.
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
              }

              for item in items {
                renderItem(item)
              }

              if !bottomItems.isEmpty {
                li {}
                  .ariaHidden(true)
                  .class("admin-sidebar-divider")
              }

              for item in bottomItems {
                renderItem(item, linkClass: "sidebar-link sidebar-back-link")
              }
            }
            .class("admin-sidebar-list")
          }
        }
        .class("admin-sidebar-content")
        .style {
          selector("&") { padding(0) }
          selector(".sidebar-title") {
            fontSize(fontSizeXSmall12)
            fontFamily(typographyFontSans)
            fontWeight(fontWeightSemiBold)
            color(colorSubtle)
            textTransform(.uppercase)
            letterSpacing(em(0.05))
          }
          selector(".admin-sidebar-divider") {
            borderBlockStart(borderWidthBase, borderStyleBase, borderColorSubtle)
            marginInlineEnd(calc(spacing0 - spacing16))
          }
          selector(".admin-sidebar-list") {
            listStyle(.none)
            padding(0)
            margin(0)
            display(.flex)
            flexDirection(.column)
            gap(spacing16)
          }
          descendant(".sidebar-back-link") {
            paddingInline(0).important()
          }
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
