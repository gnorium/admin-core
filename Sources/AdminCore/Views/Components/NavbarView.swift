#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Navbar component for admin pages.
/// Shows the site name, username, and sign out link.
private let baseRoute = Configuration.shared.baseRoute

public struct NavbarView: HTMLProtocol {
	let siteName: String
	let username: String

	public init(siteName: String = "Admin Console", username: String) {
		self.siteName = siteName
		self.username = username
	}

	public func render(indent: Int = 0) -> String {
		nav {
			div {
				a { siteName }
                .href(baseRoute)
                .style {
                    fontFamily(typographyFontSans)
                    fontSize(fontSizeLarge18)
                    fontWeight(700)
                    color(colorBase)
                    textDecoration(.none)
                    letterSpacing(px(0.5))
                    textTransform(.uppercase)
                }
			}
			.style {
				display(.flex)
				alignItems(.center)
			}

			div {
                // Theme Settings
                div {
                    ColorSchemeButtonGroupView()
                    ContrastButtonGroupView()
                }
                .style {
                    display(.flex)
                    flexDirection(.column)
                    gap(spacing8)
                    paddingRight(spacing24)
                    borderRight(borderWidthBase, borderStyleBase, borderColorSubtle)
                }

                div {
                    span { "Welcome, " }
                    .style {
                        fontSize(fontSizeSmall14)
                        color(colorSubtle)
                    }
                    span { username }
                    .style {
                        fontSize(fontSizeSmall14)
                        fontWeight(600)
                        color(colorBase)
                    }
                }
                .style {
                    display(.flex)
                    alignItems(.center)
                    gap(spacing4)
                }

				ButtonView(label: "Sign Out", weight: .quiet, size: .large, url: "\(baseRoute)/sign-out")
			}
			.style {
				display(.flex)
				gap(spacing24)
				alignItems(.center)
			}
		}
		.class("navbar-view")
		.style {
			backgroundColor(backgroundColorBase)
			padding(spacing16, spacing32)
			display(.flex)
			justifyContent(.spaceBetween)
			alignItems(.center)
			borderBottom(borderWidthBase, borderStyleBase, borderColorSubtle)
		}
		.render(indent: indent)
	}
}

#endif
