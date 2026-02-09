#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

private let baseRoute = Configuration.shared.baseRoute

public struct SidebarItem: Sendable {
    public let label: String
    public let url: String
    public let icon: (@Sendable (Length) -> [HTMLProtocol])?
    
    public init(label: String, url: String, icon: (@Sendable (Length) -> [HTMLProtocol])? = nil) {
        self.label = label
        self.url = url
        self.icon = icon
    }
}

public struct SidebarView: HTMLProtocol {
    let items: [SidebarItem]
    let bottomItems: [SidebarItem]

    public init(items: [SidebarItem]? = nil, bottomItems: [SidebarItem]? = nil) {
        self.items = items ?? [
            SidebarItem(label: "Dashboard", url: baseRoute),
            SidebarItem(label: "Invites", url: "\(baseRoute)/invites"),
            SidebarItem(label: "Security", url: "\(baseRoute)/mfa/setup")
        ]
        self.bottomItems = bottomItems ?? [
            SidebarItem(label: "Back to site", url: "/", icon: { size in
                [PreviousIconView(width: size, height: size)]
            })
        ]
    }

    public func render(indent: Int = 0) -> String {
        aside {
            div {
                nav {
                    ul {
                        // Section header
                        li {
                            h6 { "Admin Console" }
                            .style {
                                fontSize(fontSizeXSmall12)
                                fontFamily(typographyFontSans)
                                fontWeight(fontWeightBold)
                                color(colorSubtle)
                                textTransform(.uppercase)
                                letterSpacing(em(0.05))
                                margin(0)
                                paddingBlock(spacing12)
                            }
                        }
                        .style {
                            paddingBlockStart(spacing8)
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
                        gap(spacing4)

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
        .class("sidebar-view")
        .data("sidebar", true)
        .style {
            // Mobile: hidden (content is cloned to navbar mobile menu by hydration)
            display(.none)

            // Desktop: visible as sidebar
            media(minWidth(minWidthBreakpointTablet)) {
                display(.flex).important()
                flexDirection(.column)
                width(px(260))
                minWidth(px(260))
                height(vh(100))
                position(.sticky)
                top(0)
                left(0)
                backgroundColor(backgroundColorBase)
                borderRight(borderWidthBase, borderStyleBase, borderColorSubtle)
                overflow(.auto)
            }
        }
        .render(indent: indent)
    }

    @HTMLBuilder
    private func renderItem(_ item: SidebarItem, linkClass: String = "sidebar-link") -> HTMLProtocol {
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
