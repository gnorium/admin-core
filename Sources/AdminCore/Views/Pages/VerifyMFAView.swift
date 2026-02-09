#if !os(WASI)

import HTMLBuilder
import CSSBuilder
import DesignTokens
import WebComponents
import WebTypes

private let baseRoute = Configuration.shared.baseRoute

/// MFA Verification View for login flow
public struct VerifyMFAView: HTMLProtocol {
	public let username: String
	public let error: String?

	public init(username: String, error: String? = nil) {
		self.username = username
		self.error = error
	}

	public func render(indent: Int = 0) -> String {
		div {
			// verificationCard
			div {
                div {
                    p {
                        "Enter the 6-digit code from your authenticator app to verify your identity."
                    }
                    .class("verify-mfa-description")
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(fontSizeMedium16)
                        lineHeight(1.5)
                        color(colorSubtle)
                    }

                    p { "Logging in as @\(username)" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(fontSizeSmall14)
                        color(colorBase)
                        fontWeight(fontWeightNormal)
                    }
                }
                .style {
                    display(.flex)
                    flexDirection(.column)
                    gap(spacing8)
                }

                // Error message
                if let error = error {
                    div {
                        p { error }
						.class("verify-mfa-error-text")
						.style {
							fontFamily(typographyFontSans)
							color(colorRed)
							fontSize(fontSizeSmall14)
							margin(0)
						}
                    }
                    .class("verify-mfa-error-container")
                    .style {
                        backgroundColor(backgroundColorRedSubtle)
                        border(borderWidthBase, .solid, borderColorRed)
                        borderRadius(borderRadiusBase)
                        padding(spacing12)
                    }
                }

                // Verification form
                form {
                    input()
                        .type(.hidden)
                        .name("username")
                        .value(username)

                    div {
                        label { "Verification Code" }
                            .for("code")
                            .class("verify-mfa-label")
                            .style {
                                fontFamily(typographyFontSans)
                                fontSize(fontSizeXSmall12)
                                fontWeight(fontWeightNormal)
                                textTransform(.uppercase)
                                letterSpacing(px(0.5))
                                color(colorSubtle)
                            }

                        input()
                            .type(.text)
                            .name("code")
                            .id("code")
                            .placeholder("000000")
                            .required(true)
                            .class("verify-mfa-input")
                            .style {
                                fontFamily(typographyFontMono)
                                width(perc(100))
                                padding(spacing12)
                                fontSize(px(24))
                                textAlign(.center)
                                letterSpacing(px(4))
                                border(borderWidthBase, borderStyleBase, borderColorBase)
                                borderRadius(borderRadiusBase)
                                backgroundColor(backgroundColorNeutralSubtle)
                                color(colorBase)
                            }
                    }
                    .class("verify-mfa-form-group")
                    .style {
                        display(.flex)
                        flexDirection(.column)
                        alignItems(.flexStart)
                        gap(spacing8)
                        width(perc(100))
                    }

                    div {
                        ButtonView(
                            label: "Verify & Login",
                            buttonColor: .blue,
                            weight: .solid,
                            size: .large,
                            type: .submit,
                            fullWidth: true,
                            class: "verify-mfa-button"
                        )
                    }
                    .style {
                        width(perc(100))
                    }
                }
                .method(.post)
                .action("\(baseRoute)/mfa/verify")
                .style {
                    display(.flex)
                    flexDirection(.column)
                    gap(spacing32)
                    width(perc(100))
                }

                // Footer
                div {
                    a { "Back to login" }
                        .href("\(baseRoute)/sign-in")
                        .class("verify-mfa-back-link")
                        .style {
                            fontFamily(typographyFontSans)
                            fontSize(fontSizeSmall14)
                            color(colorSubtle)
                            textDecoration(.none)
                        }
                }
                .class("verify-mfa-footer")
                .style {
                    borderTop(borderWidthBase, borderStyleBase, borderColorBase)
                    paddingTop(spacing24)
                }
            }
            .class("verify-mfa-card")
            .style {
                backgroundColor(backgroundColorBase)
                border(borderWidthBase, borderStyleBase, borderColorBase)
                borderRadius(borderRadiusBase)
                padding(spacing48)
                width(px(480))
                maxWidth(perc(100))
                boxShadow(boxShadowLarge)
                textAlign(.center)
                display(.flex)
                flexDirection(.column)
                gap(spacing32)
                margin(0, .auto)
            }
        }
        .class("verify-mfa-view")
        .style {
            display(.flex)
            justifyContent(.center)
            alignItems(.center)
            minHeight(vh(80))
            padding(spacing24)
        }
        .render(indent: indent)
    }
}

#endif

#if os(WASI)
 
 import WebAPIs
 import EmbeddedSwiftUtilities
 
 /// WASM Hydration for VerifyMFAView
 public class VerifyMFAHydration: @unchecked Sendable {
 	public init() {
 		hydrate()
 	}
 
 	public func hydrate() {
 		// Focus the code input field automatically
 		if let codeInput = document.getElementById("code") {
 			codeInput.focus()
 		}
 	}
 }
 
 #endif
