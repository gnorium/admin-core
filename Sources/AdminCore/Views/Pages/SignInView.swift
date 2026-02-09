#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

private let baseRoute = Configuration.shared.baseRoute

/// Sign in form component for admin authentication.
/// Use with AdminCore.LayoutView for the full page.
public struct SignInView: HTMLProtocol {
	let errorMessage: String?

	public init(errorMessage: String? = nil) {
		self.errorMessage = errorMessage
	}

	public func render(indent: Int = 0) -> String {
		div {
			div {
				div {
					h1 { "Sign In" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(fontSizeXXXLarge28)
                        fontWeight(fontWeightNormal)
                        color(colorBase)
                        margin(0)
                    }

					p { "Sign in to manage content" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(fontSizeSmall14)
                        color(colorSubtle)
                        margin(0)
                    }
				}
				.style {
					display(.flex)
					flexDirection(.column)
					gap(spacing12)
					textAlign(.center)
				}

				if let error = errorMessage, !error.isEmpty {
					div {
						p { error }
						.style {
							margin(0)
							fontSize(fontSizeSmall14)
							color(colorRed)
						}
					}
					.class("error-banner")
					.style {
						backgroundColor(backgroundColorRedSubtle)
						border(borderWidthBase, .solid, borderColorRed)
						borderRadius(borderRadiusBase)
						padding(spacing12, spacing16)
					}
				}

				form {
					div {
                        FieldView(id: "username") {
                            "Username"
                        } input: {
                            TextInputView(id: "username", name: "username", placeholder: "Enter your username", required: true)
                        }
					}

					div {
                        FieldView(id: "password") {
                            "Password"
                        } input: {
                            TextInputView(id: "password", name: "password", placeholder: "Enter your password", type: .password, required: true)
                        }
					}

					ButtonView(label: "Sign In", buttonColor: .blue, weight: .solid, size: .large, type: .submit, fullWidth: true)

					div {
                        a { "← Back to Site" }
                            .href("/")
                            .style {
                                display(.inlineBlock)
                                fontSize(fontSizeSmall14)
                                color(colorSubtle)
                                textDecoration(.none)
                                fontFamily(typographyFontSans)
                                fontWeight(500)
                                
                                pseudoClass(.hover) {
                                    color(colorBase)
                                }
                            }
					}
					.style {
						textAlign(.center)
					}
				}
				.action("\(baseRoute)/sign-in")
				.method(.post)
				.style {
					display(.flex)
					flexDirection(.column)
					gap(spacing24)
				}
			}
			.style {
				display(.flex)
				flexDirection(.column)
				gap(spacing32)
				width(perc(100))
				maxWidth(px(480))
				backgroundColor(backgroundColorBase)
				border(borderWidthBase, borderStyleBase, borderColorSubtle)
				borderRadius(borderRadiusBase)
				padding(spacing40)
			}
		}
		.class("sign-in-view")
		.style {
			display(.flex)
			justifyContent(.center)
			alignItems(.center)
		}
		.render(indent: indent)
	}
}

#endif
