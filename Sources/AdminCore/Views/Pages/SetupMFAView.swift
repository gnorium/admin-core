#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// MFA enrollment page: QR code / otpauth URL and shared secret for authenticator apps.
  public struct SetupMFAView: HTMLContent {
    /// TOTP shared secret (base32).
    public let secret: String
    /// Full `otpauth://` URL for QR encoding.
    public let otpauthURL: String
    /// Account label shown in authenticator apps.
    public let accountName: String
    /// Issuer label (e.g. product name).
    public let issuer: String
    /// Username shown in copy.
    public let username: String

    /// - Parameters:
    ///   - secret: TOTP secret.
    ///   - otpauthURL: Provisioning URI.
    ///   - accountName: Account name in the authenticator.
    ///   - issuer: Issuer string shown in authenticator apps (default `"Admin"`).
    ///   - username: Display username for the page.
    public init(
      secret: String, otpauthURL: String, accountName: String, issuer: String = "Admin",
      username: String
    ) {
      self.secret = secret
      self.otpauthURL = otpauthURL
      self.accountName = accountName
      self.issuer = issuer
      self.username = username
    }

    public func build() -> DOM.Node {
      div {
        // setupCard
        div {
          div {
            p {
              "Setting up multi-factor authentication for @\(username). MFA adds an extra layer of security to your admin account."
            }
            .class("setup-mfa-subtitle")
          }
          .class("setup-mfa-header")

          // setupContent
          div {
            // QR Code and Instructions Grid
            div {
              // QR Code (generated client-side)
              div {
                div()
                  .id("qrcode")
                  .class("setup-mfa-qrcode-canvas")
              }
              .class("setup-mfa-qrcode-container")

              // Instructions
              div {
                h3 { "Step 1: Scan QR Code" }
                  .class("setup-mfa-step-heading")
                p {
                  "Open your authenticator app (Google Authenticator, 1Password, Authy) and scan this QR code."
                }
                .class("setup-mfa-step-text")

                h3 { "Step 2: Backup Secret" }
                  .class("setup-mfa-step-heading")
                p { "If you can't scan the QR code, enter this secret manually:" }
                  .class("setup-mfa-step-text")

                // Secret display
                div {
                  code { secret }
                    .class("setup-mfa-secret-text")
                  button {
                    span {
                      IconView { CopyIconView() }
                    }
                    .class("copy-icon")

                    span {
                      IconView { CheckIconView() }
                    }
                    .class("success-icon")
                  }
                  .class("setup-mfa-copy-button")
                  .data("copied", false)
                }
                .class("setup-mfa-secret-container")
              }
            }
            .class("setup-mfa-grid")

            // Verification form
            div {
              form {
                label { "Verify Setup" }
                  .for("code")
                  .class("setup-mfa-verify-label")

                p { "Enter the 6-digit code from your app to confirm setup:" }
                  .class("setup-mfa-verify-instructions")

                div {
                  input()
                    .type(.text)
                    .name("code")
                    .id("code")
                    .placeholder("000000")
                    .required(true)
                    .class("setup-mfa-verify-input")
                }

                div {
                  ButtonView(
                    label: "Enable MFA",
                    buttonColor: .blue,
                    weight: .solid,
                    size: .large,
                    type: .submit,
                    class: "setup-mfa-enable-button"
                  )
                }
              }
              .method(.post)
              .action("\(baseRoute)/mfa/setup")
              .class("setup-mfa-verify-form")
            }
            .class("setup-mfa-verify-section")
          }
          .class("setup-mfa-content")

          // setupFooter
          div {
            a { "Cancel and return to dashboard" }
              .href(baseRoute)
              .class("setup-mfa-cancel-link")
          }
          .class("setup-mfa-footer")
        }
        .class("setup-mfa-card")
      }
      .class("setup-mfa-view")
      .data("otpauth-url", otpauthURL)
      .style {
        selector("&") {
          display(.flex)
          justifyContent(.center)
          alignItems(.center)
          minHeight(vh(80))
        }
        descendant(".setup-mfa-card") {
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
        descendant(".setup-mfa-header") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
        }
        descendant(".setup-mfa-subtitle") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          color(colorSubtle)
          textAlign(.center)
        }
        descendant(".setup-mfa-content") {
          display(.flex)
          flexDirection(.column)
          gap(spacing48)
        }
        descendant(".setup-mfa-grid") {
          display(.flex)
          flexDirection(.column)
          gap(spacing48)
          alignItems(.center)
        }
        descendant(".setup-mfa-qrcode-canvas") {
          width(px(200))
          height(px(200))
        }
        descendant(".setup-mfa-qrcode-container") {
          backgroundColor(hex(0xFFFFFF))
          padding(spacing16)
          borderRadius(borderRadiusBase)
          boxShadow(px(0), px(2), px(10), px(0), rgba(0, 0, 0, 0.05))
          display(.flex)
          justifyContent(.center)
          alignItems(.center)
        }
        descendant(".setup-mfa-step-heading") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          fontWeight(fontWeightNormal)
          color(colorBase)
          marginBottom(spacing8)
          marginTop(spacing24)
        }
        descendant(".setup-mfa-step-text") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          lineHeight(1.5)
          color(colorSubtle)
          margin(0)
        }
        descendant(".setup-mfa-secret-container") {
          display(.flex)
          alignItems(.center)
          backgroundColor(backgroundColorNeutralSubtle)
          padding(spacing8, spacing12)
          borderRadius(borderRadiusBase)
          marginTop(spacing12)
          border(borderWidthBase, borderStyleBase, borderColorBase)
        }
        descendant(".setup-mfa-secret-text") {
          fontFamily(typographyFontMono)
          fontSize(fontSizeSmall14)
          color(colorBlue)
          flexGrow(1)
          wordBreak(.breakAll)
          overflowWrap(.anywhere)
          marginRight(spacing8)
        }
        descendant(".setup-mfa-copy-button") {
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
        }
        descendant(".setup-mfa-copy-button .success-icon") { display(.none) }
        descendant(".setup-mfa-copy-button[data-copied='true'] .copy-icon") { display(.none) }
        descendant(".setup-mfa-copy-button[data-copied='true'] .success-icon") { display(.flex) }
        descendant(".setup-mfa-copy-button:hover") {
          backgroundColor(backgroundColorInteractiveSubtleHover).important()
          color(colorBase).important()
        }
        descendant(".setup-mfa-verify-section") {
          borderTop(borderWidthBase, borderStyleBase, borderColorBase)
          paddingTop(spacing32)
          textAlign(.center)
          display(.flex)
          flexDirection(.column)
          alignItems(.center)
          gap(spacing32)
        }
        descendant(".setup-mfa-verify-form") {
          display(.flex)
          flexDirection(.column)
          alignItems(.center)
          gap(spacing24)
        }
        descendant(".setup-mfa-verify-label") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          fontWeight(fontWeightNormal)
          color(colorBase)
          display(.block)
        }
        descendant(".setup-mfa-verify-instructions") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          margin(0)
        }
        descendant(".setup-mfa-verify-input") {
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
        descendant(".setup-mfa-footer") { textAlign(.center) }
        descendant(".setup-mfa-cancel-link") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          textDecoration(.none)
        }
      }

    }
  }
#endif

#if CLIENT
  import DOMBuilder
  import EmbeddedSwiftUtilities
  import HTMLBuilder
  import WebAPIs
  import WebTypes

  /// Client hydration for ``SetupMFAView`` (QR render, copy secret).
  public class SetupMFAHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: SetupMFAHydration?

    public static func hydrateIfPresent() {
      guard document.querySelector(".setup-mfa-view") != nil else { return }
      instance = SetupMFAHydration()
    }

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
      copyButton?.addEventListener(.click) { (event: Event) in
        guard let text = secretText?.textContent else { return }

        // Copy to clipboard
        window.navigator.clipboard.writeText(text)

        // Show success feedback
        copyButton?.setAttribute(data("copied"), true)

        // Revert after 2 seconds
        _ = window.setTimeout(2000) {
          copyButton?.setAttribute(data("copied"), false)
        }
      }
    }
  }
#endif
