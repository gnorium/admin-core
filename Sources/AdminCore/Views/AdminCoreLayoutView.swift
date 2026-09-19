#if SERVER
  import CSSBuilder
  import CSSOMBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// Shared layout fragment for the admin panel.
  /// Provides the Sidebar + Navbar + Content structure.
  /// Designed to be nested inside an app-level LayoutView.
  /// Named for its package: the emitter names each stylesheet after the TYPE,
  /// so two `LayoutView`s in two packages emitted into one `layout-view.css`
  /// and AdminCore's rules shipped to every Gnorium page.
  public struct AdminCoreLayoutView: HTMLContent {
    let siteName: String
    let username: String
    let showNavbar: Bool
    let showSidebar: Bool
    let navbar: [DOM.Node]?
    let sidebar: [DOM.Node]?
    let content: [DOM.Node]
    let signOutUrl: String?

    public init(
      siteName: String = "Admin Console",
      username: String = "",
      navbar: [DOM.Node]? = nil,
      sidebar: [DOM.Node]? = nil,
      showNavbar: Bool = false,
      showSidebar: Bool = false,
      signOutUrl: String? = nil,
      @HTMLBuilder content: () -> [DOM.Node]
    ) {
      self.siteName = siteName
      self.username = username
      self.navbar = navbar
      self.sidebar = sidebar
      self.showNavbar = showNavbar
      self.showSidebar = showSidebar
      self.signOutUrl = signOutUrl ?? "\(Configuration.shared.baseRoute)/sign-out"
      self.content = content()
    }

    public func build() -> DOM.Node {
      div {
        if let sidebar = sidebar {
          sidebar
        } else if showSidebar {
          SidebarView()
        }

        div {
          if let navbar = navbar {
            navbar
          } else if showNavbar {
            NavbarView(siteName: siteName, username: username, signOutUrl: signOutUrl)
          }

          main {
            content
          }
          .class("admin-core-content")
          .style {
            selector("&") {
              flex(1)
              overflow(.auto)
              minWidth(0)
              boxSizing(.borderBox)
            }
          }
        }
        .class("layout-inner-div admin-core")
        .style {
          selector("&") {
            display(.flex)
            flexDirection(.column)
            flex(1)
            minWidth(0)
          }
          media(minWidth(minWidthBreakpointTablet)) {
            padding(spacing32)
          }
        }
      }
      // NOT "layout-view": gnorium-web's own LayoutView owns that class, and
      // stylesheets are global — this block's `overflow: hidden` was landing on
      // every Gnorium page's root element and clipping it, so nothing scrolled.
      .class("admin-core-layout-view admin-core")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.row)
          flex(1)
          minHeight(0)
          width(perc(100))
          overflow(.hidden)
          fontFamily(typographyFontSans)
        }
      }

    }
  }

#endif
