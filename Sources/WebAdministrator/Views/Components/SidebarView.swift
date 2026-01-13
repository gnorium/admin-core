#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

public struct SidebarView: HTML {
    public init() {}

    public func render(indent: Int = 0) -> String {
        aside {
            div {
                nav {
                    ul {
                        li {
                            a { "Dashboard" }
                                .href("/administrator")
                                .class("sidebar-link")
                                .style { sidebarLinkStyle() }
                        }
                        li {
                            a { "Articles" }
                                .href("/administrator/articles")
                                .class("sidebar-link")
                                .style { sidebarLinkStyle() }
                        }
                        li {
                            a { "Invites" }
                                .href("/administrator/invites")
                                .class("sidebar-link")
                                .style { sidebarLinkStyle() }
                        }
                        li {
                            a { "Users" }
                                .href("/administrator/users")
                                .class("sidebar-link")
                                .style { sidebarLinkStyle() }
                        }
                        li {
                            div { "" }
                                .style {
                                    borderTop(borderWidthBase, borderStyleBase, borderColorSubtle)
                                    marginTop(spacing8)
                                    paddingTop(spacing8)
                                }
                        }
                        li {
                            a {
                                div {
                                    IconView(icon: { size in
                                        PreviousIconView(width: size, height: size)
                                    }, size: .small)
                                    span { "Back to site" }
                                }
                                .style {
                                    display(.flex)
                                    alignItems(.center)
                                    gap(spacing8)
                                }
                            }
                            .href("/")
                            .class("sidebar-link")
                            .style { sidebarLinkStyle() }
                        }
                    }
                    .style {
                        listStyle(.none)
                        padding(0)
                        margin(0)
                        display(.flex)
                        flexDirection(.column)
                    }
                }
            }
            .style {
                padding(spacing16)
            }
        }
        .class("sidebar-view")
        .style {
            width(px(260))
            height(vh(100))
            position(.fixed)
            top(0)
            left(0)
            backgroundColor(backgroundColorBase)
            borderRight(borderWidthBase, borderStyleBase, borderColorSubtle)
            display(.flex)
            flexDirection(.column)
            zIndex(zIndexBase)
            paddingTop(px(64)) // Height of navbar
        }
        .render(indent: indent)
    }

    @CSSBuilder
    private func sidebarLinkStyle() -> [any CSS] {
        display(.block)
        padding(spacing12, spacing16)
        fontFamily(typographyFontSans)
        fontSize(fontSizeSmall14)
        fontWeight(500)
        color(colorBase)
        textDecoration(.none)
        borderRadius(borderRadiusBase)
        transition(transitionPropertyBase, transitionDurationBase, transitionTimingFunctionSystem)
        
        pseudoClass(.hover) {
            backgroundColor(backgroundColorInteractiveSubtleHover)
            color(colorBase)
        }
    }
}

#endif
