#if !os(WASI)

import HTMLBuilder
import CSSBuilder
import DesignTokens
import WebComponents
import WebTypes

private let baseRoute = Configuration.shared.baseRoute

/// MFA Setup View with QR code for authenticator app configuration
/// Uses LayoutView for consistent admin panel structure
public struct SetupMFAView: HTML {
	public let secret: String
	public let otpauthURL: String
	public let accountName: String
	public let issuer: String

	public init(secret: String, otpauthURL: String, accountName: String, issuer: String = "Gnorium") {
		self.secret = secret
		self.otpauthURL = otpauthURL
		self.accountName = accountName
		self.issuer = issuer
	}

	public func render(indent: Int = 0) -> String {
        div {
            // setupCard
            div {
                div {
                    h1 { "Secure Your Account" }
                        .class("setup-mfa-title")
                        .style {
                            fontFamily(typographyFontSans)
                            fontSize(px(32))
                            fontWeight(600)
                            color(colorBase)
                            textAlign(.center)
                            letterSpacing(px(-0.5))
                        }

                    p { "Multi-factor authentication (MFA) adds an extra layer of security to your admin account." }
                        .class("setup-mfa-subtitle")
                        .style {
                            fontFamily(typographyFontSans)
                            fontSize(fontSizeMedium16)
                            color(colorSubtle)
                            textAlign(.center)
                        }
                }
                .style {
                    display(.flex)
                    flexDirection(.column)
                    gap(spacing8)
                }

                // setupContent
                div {
                    // QR Code and Instructions Grid
                    div {
                        // QR Code (generated client-side)
                        div {
                            div()
                                .id("qrcode")
                                .class("setup-mfa-qrcode-canvas")
                                .style {
                                    width(px(200))
                                    height(px(200))
                                }
                        }
                        .class("setup-mfa-qrcode-container")
                        .style {
                            backgroundColor(hex(0xFFFFFF))
                            padding(spacing16)
                            borderRadius(borderRadiusBase)
                            boxShadow(px(0), px(2), px(10), px(0), rgba(0, 0, 0, 0.05))
                            display(.flex)
                            justifyContent(.center)
                            alignItems(.center)
                        }

                        // Instructions
                        div {
                            h3 { "Step 1: Scan QR Code" }
                                .class("setup-mfa-step-heading")
                                .style {
                                    fontFamily(typographyFontSans)
                                    fontSize(fontSizeMedium16)
                                    fontWeight(.semiBold)
                                    color(colorBase)
                                    marginBottom(spacing8)
                                    marginTop(spacing24)
                                }
                            p { "Open your authenticator app (Google Authenticator, 1Password, Authy) and scan this QR code." }
                                .class("setup-mfa-step-text")
                                .style {
                                    fontFamily(typographyFontSans)
                                    fontSize(fontSizeSmall14)
                                    lineHeight(1.5)
                                    color(colorSubtle)
                                    margin(0)
                                }

                            h3 { "Step 2: Backup Secret" }
                                .class("setup-mfa-step-heading")
                                .style {
                                    fontFamily(typographyFontSans)
                                    fontSize(fontSizeMedium16)
                                    fontWeight(.semiBold)
                                    color(colorBase)
                                    marginBottom(spacing8)
                                    marginTop(spacing24)
                                }
                            p { "If you can't scan the QR code, enter this secret manually:" }
                                .class("setup-mfa-step-text")
                                .style {
                                    fontFamily(typographyFontSans)
                                    fontSize(fontSizeSmall14)
                                    lineHeight(1.5)
                                    color(colorSubtle)
                                    margin(0)
                                }

                            // Secret display
                            div {
                                code { secret }
                                    .class("setup-mfa-secret-text")
                                    .style {
                                        fontFamily(typographyFontMono)
                                        fontSize(fontSizeSmall14)
                                        color(colorProgressive)
                                        flexGrow(1)
                                        wordBreak(.breakAll)
                                        overflowWrap(.anywhere)
                                        marginRight(spacing8)
                                    }
                                button {
                                    span {
                                        IconView { CopyIconView() }
                                    }
                                    .class("copy-icon")
                                    
                                    span {
                                        IconView { CheckIconView() }
                                    }
                                    .class("success-icon")
                                    .style { display(.none) }
                                }
                                .class("setup-mfa-copy-button")
                                .style {
                                    display(.flex)
                                    alignItems(.center)
                                    justifyContent(.center)
                                    padding(spacing8)
                                    backgroundColor(.transparent)
                                    border(.none)
                                    borderRadius(borderRadiusBase)
                                    cursor(.pointer)
                                    color(colorSubtle)
                                    transition("all", ms(200))

                                    pseudoClass(.hover) {
                                        backgroundColor(backgroundColorInteractiveSubtleHover).important()
                                        color(colorBase).important()
                                    }
                                }
                            }
                            .class("setup-mfa-secret-container")
                            .style {
                                display(.flex)
                                alignItems(.center)
                                backgroundColor(backgroundColorNeutralSubtle)
                                padding(spacing8, spacing12)
                                borderRadius(borderRadiusBase)
                                marginTop(spacing12)
                                border(borderWidthBase, borderStyleBase, borderColorBase)
                            }
                        }
                    }
                    .class("setup-mfa-grid")
                    .style {
                        display(.grid)
                        gridTemplateColumns(px(240), fr(1))
                        gap(spacing48)
                        alignItems(.flexStart)
                    }

                    // Verification form
                    div {
                        form {
                            label { "Verify Setup" }
                                .for("code")
                                .class("setup-mfa-verify-label")
                                .style {
                                    fontFamily(typographyFontSans)
                                    fontSize(fontSizeMedium16)
                                    fontWeight(.semiBold)
                                    color(colorBase)
                                    display(.block)
                                }

                            p { "Enter the 6-digit code from your app to confirm setup:" }
                                .class("setup-mfa-verify-instructions")
                                .style {
                                    fontFamily(typographyFontSans)
                                    fontSize(fontSizeSmall14)
                                    color(colorSubtle)
                                    margin(0)
                                }

                            div {
                                input()
                                    .type(.text)
                                    .name("code")
                                    .id("code")
                                    .placeholder("000000")
                                    .required(true)
                                    .class("setup-mfa-verify-input")
                                    .style {
                                        fontFamily(typographyFontMono)
                                        width(px(200))
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

                            div {
                                ButtonView(
                                    label: "Enable MFA",
                                    action: .progressive,
                                    weight: .primary,
                                    size: .large,
                                    type: .submit,
                                    class: "setup-mfa-enable-button"
                                )
                            }
                        }
                        .method(.post)
                        .action("\(baseRoute)/mfa/setup")
                        .style {
                            display(.flex)
                            flexDirection(.column)
                            alignItems(.center)
                            gap(spacing24)
                        }
                    }
                    .class("setup-mfa-verify-section")
                    .style {
                        borderTop(borderWidthBase, borderStyleBase, borderColorBase)
                        paddingTop(spacing32)
                        textAlign(.center)
                        display(.flex)
                        flexDirection(.column)
                        alignItems(.center)
                        gap(spacing32)
                    }
                }
                .class("setup-mfa-content")
                .style {
                    display(.flex)
                    flexDirection(.column)
                    gap(spacing48)
                }

                // setupFooter
                div {
                    a { "Cancel and return to dashboard" }
                    .href(baseRoute)
                    .class("setup-mfa-cancel-link")
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(fontSizeSmall14)
                        color(colorSubtle)
                        textDecoration(.none)
                    }
                }
                .class("setup-mfa-footer")
                .style {
                    textAlign(.center)
                }
            }
            .class("setup-mfa-card")
            .style {
                backgroundColor(backgroundColorBase)
                border(borderWidthBase, borderStyleBase, borderColorBase)
                borderRadius(borderRadiusBase)
                padding(spacing48)
                width(perc(100))
                maxWidth(px(800))
                boxShadow(boxShadowLarge)
                display(.flex)
                flexDirection(.column)
                gap(spacing24)
                margin(0, .auto)
            }
        }
        .class("setup-mfa-view")
        .data("otpauth-url", otpauthURL)
        .style {
            display(.flex)
            justifyContent(.center)
            alignItems(.center)
            minHeight(vh(80))
        }
        .render(indent: indent)
    }
}

#endif

#if os(WASI)

import WebAPIs
import EmbeddedSwiftUtilities

/// WASM Hydration for SetupMFAView
public class SetupMFAHydration: @unchecked Sendable {
	public init() {
		hydrate()
	}

	public func hydrate() {
		let container = document.querySelector(".setup-mfa-view")
		guard let otpauthURL = container?.dataset["otpauth-url"] else { return }
		
		let qrcodeElement = document.getElementById("qrcode")
		guard let element = qrcodeElement else { return }

		QRCode(element, text: otpauthURL)

		// Clipboard feedback
		let copyButton = container?.querySelector(".setup-mfa-copy-button")
		let secretText = container?.querySelector(".setup-mfa-secret-text")
		let copyIcon = copyButton?.querySelector(".copy-icon")
		let successIcon = copyButton?.querySelector(".success-icon")

		copyButton?.addEventListener("click") { _ in
			guard let text = secretText?.textContent else { return }
			
			// Copy to clipboard
			window.navigator.clipboard.writeText(text)

			// Show success feedback
			copyIcon?.style.display(.none)
			successIcon?.style.display(.flex)

			// Revert after 2 seconds
			_ = window.setTimeout(2000) {
				copyIcon?.style.display(.flex)
				successIcon?.style.display(.none)
			}
		}
	}
}

#endif
