#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Login form component for administrator authentication.
/// Use with WebAdministrator.LayoutView for the full page.
public struct LoginView: HTML {
	let errorMessage: String?

	public init(errorMessage: String? = nil) {
		self.errorMessage = errorMessage
	}

	public func render(indent: Int = 0) -> String {
		div {
			div {
				div {
					h1 { "Administrator" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(px(32))
                        fontWeight(600)
                        color(colorBase)
                        marginBottom(spacing8)
                        letterSpacing(px(-0.5))
                    }

					p { "Sign in to manage content" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(fontSizeSmall14)
                        color(colorSubtle)
                        letterSpacing(px(0.2))
                    }
				}
				.style {
					textAlign(.center)
					marginBottom(spacing32)
				}

				if let error = errorMessage {
					div { error }
                    .style {
                        backgroundColor(backgroundColorErrorSubtle)
                        color(colorError)
                        padding(spacing12, spacing16)
                        borderRadius(borderRadiusBase)
                        marginBottom(spacing24)
                        fontSize(fontSizeSmall14)
                        fontWeight(500)
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
					.style {
						marginBottom(spacing24)
					}

					div {
                        FieldView(id: "password") {
                            "Password"
                        } input: {
                            TextInputView(id: "password", name: "password", placeholder: "Enter your password", type: .password, required: true)
                        }
					}
					.style {
						marginBottom(spacing32)
					}

					ButtonView(label: "Sign In", action: .progressive, weight: .primary, type: .submit, fullWidth: true)

					div {
                        a { "← Back to Site" }
                            .href("/")
                            .style {
                                display(.inlineBlock)
                                marginTop(spacing24)
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
				.action("/administrator/login")
				.method(.post)
			}
			.style {
				width(perc(100))
				maxWidth(px(400))
				backgroundColor(backgroundColorBase)
				border(borderWidthBase, borderStyleBase, borderColorBase)
				borderRadius(borderRadiusBase) // More modern look with standard radius
				boxShadow(boxShadowLarge)
				padding(spacing48)
			}
		}
		.class("login-container")
		.style {
			display(.flex)
			justifyContent(.center)
			alignItems(.center)
			minHeight(vh(100))
			padding(spacing16)
			backgroundColor(backgroundColorNeutralSubtle)
		}
		.render(indent: indent)
	}
}

#endif
