#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Navbar component for administrator pages.
/// Shows the site name, username, and logout link.
public struct NavbarView: HTML {
	let siteName: String
	let username: String

	public init(siteName: String = "Administrator", username: String) {
		self.siteName = siteName
		self.username = username
	}

	public func render(indent: Int = 0) -> String {
		nav {
			div {
				a { siteName }
                .href("/administrator")
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
                // Theme Toggles
                div {
                    ColorSchemeToggleView()
                    ContrastToggleView()
                }
                .style {
                    display(.flex)
                    alignItems(.center)
                    gap(spacing16)
                    marginRight(spacing24)
                    paddingRight(spacing24)
                    borderRight(borderWidthBase, borderStyleBase, borderColorSubtle)
                }

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

				a { ButtonView(label: "Logout", weight: .quiet, size: .small) }
                .href("/administrator/logout")
                .style {
                    textDecoration(.none)
                }
			}
			.style {
				display(.flex)
				gap(spacing8)
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
			position(.fixed)
			top(0)
			left(px(260)) // Offset for sidebar
			right(0)
			zIndex(zIndexSticky)
		}
		.render(indent: indent)
	}
}

#endif
