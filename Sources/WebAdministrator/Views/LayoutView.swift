#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Shared layout for the administrator panel.
/// Provides the Sidebar + Navbar + Content structure.
public struct LayoutView: HTML {
    let siteName: String
    let username: String
    let content: HTML

    public init(
        siteName: String = "Administrator",
        username: String,
        @HTMLBuilder content: () -> HTML
    ) {
        self.siteName = siteName
        self.username = username
        self.content = content()
    }

    public func render(indent: Int = 0) -> String {
        html {
            head {
                title { "\(siteName) | Administration" }
                meta().charset(.UTF8)
                meta().name(.viewport).content("width=device-width, initial-scale=1")
            }
            body {
                div {
                    SidebarView()
                    div {
                        NavbarView(siteName: siteName, username: username)

                        main {
                            ContainerView(size: .xLarge) {
                                content
                            }
                        }
                        .style {
                            flex(1)
                            overflow(.auto)
                            padding(spacing32)
                            marginTop(px(64)) // Offset for fixed navbar
                        }

                        footer {
                            BreadcrumbView(items: [
                                .init(text: "Home", url: "/administrator"),
                                .init(text: "Dashboard")
                            ])
                        }
                        .style {
                            padding(spacing16, spacing32)
                            backgroundColor(backgroundColorBase)
                            borderTop(borderWidthBase, borderStyleBase, borderColorSubtle)
                        }
                    }
                    .style {
                        flex(1)
                        display(.flex)
                        flexDirection(.column)
                        minHeight(vh(100))
                        marginLeft(px(260)) // Offset for sidebar
                    }
                }
                .style {
                    display(.flex)
                    minHeight(vh(100))
                    backgroundColor(backgroundColorBase)
                    color(colorBase)
                    fontFamily(typographyFontSans)
                }
            }
            .style {
                margin(0)
                padding(0)
                backgroundColor(backgroundColorNeutralSubtle)
            }
        }
        .render(indent: indent)
    }
}

@CSSBuilder
public func tableHeaderCSS() -> [any CSS] {
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
public func tableRowCSS() -> [any CSS] {
    selector("td") {
        padding(spacing16, px(20))
        verticalAlign(.middle)
    }
}

#endif
