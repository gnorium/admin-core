#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

private let baseRoute = Configuration.shared.baseRoute

/// Shared layout fragment for the admin panel.
/// Provides the Sidebar + Navbar + Content structure.
/// Designed to be nested inside an app-level LayoutView.
public struct LayoutView: HTMLProtocol {
    let siteName: String
    let username: String
    let showNavbar: Bool
    let showSidebar: Bool
    let showFooter: Bool
    let navbar: HTMLProtocol?
    let sidebar: HTMLProtocol?
    let content: HTMLProtocol

    public init(
        siteName: String = "Admin Console",
        username: String = "",
        navbar: HTMLProtocol? = nil,
        sidebar: HTMLProtocol? = nil,
        showNavbar: Bool = false,
        showSidebar: Bool = false,
        showFooter: Bool = false,
        @HTMLBuilder content: () -> HTMLProtocol
    ) {
        self.siteName = siteName
        self.username = username
        self.navbar = navbar
        self.sidebar = sidebar
        self.showNavbar = showNavbar
        self.showSidebar = showSidebar
        self.showFooter = showFooter
        self.content = content()
    }

    public func render(indent: Int = 0) -> String {
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
                    NavbarView(siteName: siteName, username: username)
                }
                
                main {
                    content
                }
                .style {
                    flex(1)
                    overflow(.auto)
                }
            }
            .style {
                display(.flex)
                flexDirection(.column)
                flex(1)
            }
        }
        .style {
            display(.flex)
            flexDirection(.row)
            minHeight(perc(100))
        }
        .render(indent: indent)
    }
}

@CSSBuilder
public func tableHeaderCSS() -> [any CSSProtocol] {
    backgroundColor(backgroundColorNeutralSubtle)
    color(colorBase)
    textTransform(.uppercase)
    fontSize(fontSizeXSmall12)
    letterSpacing(em(0.05))
    fontWeight(fontWeightBold)
    padding(px(14), px(20)).important()
    borderBottom(px(1), .solid, rgba(0, 0, 0, 0.05))
    
    selector("a") {
        color(colorBase).important()
        textDecoration(.none)
    }
}

@CSSBuilder
public func tableRowCSS() -> [any CSSProtocol] {
    selector("td") {
        padding(spacing16, px(20))
        verticalAlign(.middle)
    }
}

#endif
