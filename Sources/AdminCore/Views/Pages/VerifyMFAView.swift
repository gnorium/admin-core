#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// MFA challenge step after password sign-in (6-digit TOTP form).
  public struct VerifyMFAView: HTMLContent {
    /// Username of the account being verified.
    public let username: String
    /// Optional error message from a failed attempt.
    public let error: String?

    /// - Parameters:
    ///   - username: Account being verified.
    ///   - error: Optional error banner text.
    public init(username: String, error: String? = nil) {
      self.username = username
      self.error = error
    }

    public func build() -> DOM.Node {
      div {
        // verificationCard
        div {
          div {
            p {
              "Enter the 6-digit code from your authenticator app to verify your identity."
            }
            .class("verify-mfa-description")

            p { "Logging in as @\(username)" }
              .class("verify-mfa-identity")
          }
          .class("verify-mfa-header")

          // Error message
          if let error = error {
            div {
              p { error }
                .class("verify-mfa-error-text")
            }
            .class("verify-mfa-error-container")
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

              input()
                .type(.text)
                .name("code")
                .id("code")
                .placeholder("000000")
                .required(true)
                .class("verify-mfa-input")
            }
            .class("verify-mfa-form-group")

            div {
              ButtonView(
                label: "Verify & Login",
                buttonColor: .blue,
                weight: .solid,
                size: .medium,
                type: .submit,
                fullWidth: true,
                class: "verify-mfa-button"
              )
            }
            .class("verify-mfa-submit-container")
          }
          .method(.post)
          .action("\(baseRoute)/mfa/verify")
          .class("verify-mfa-form")

          // Footer
          div {
            a { "Back to login" }
              .href("\(baseRoute)/sign-in")
              .class("verify-mfa-back-link")
          }
          .class("verify-mfa-footer")
        }
        .class("verify-mfa-card")
      }
      .class("verify-mfa-view")
      .style {
        selector("&") {
          display(.flex)
          justifyContent(.center)
          alignItems(.center)
          minHeight(vh(80))
          padding(spacing24)
        }
        descendant(".verify-mfa-card") {
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
        descendant(".verify-mfa-header") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
        }
        descendant(".verify-mfa-description") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          lineHeight(1.5)
          color(colorSubtle)
        }
        descendant(".verify-mfa-identity") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          color(colorBase)
          fontWeight(fontWeightNormal)
        }
        descendant(".verify-mfa-error-container") {
          backgroundColor(backgroundColorRedSubtle)
          border(borderWidthBase, .solid, borderColorRed)
          borderRadius(borderRadiusBase)
          padding(spacing12)
        }
        descendant(".verify-mfa-error-text") {
          fontFamily(typographyFontSans)
          color(colorRed)
          fontSize(fontSizeSmall14)
          margin(0)
        }
        descendant(".verify-mfa-form") {
          display(.flex)
          flexDirection(.column)
          gap(spacing32)
          width(perc(100))
        }
        descendant(".verify-mfa-form-group") {
          display(.flex)
          flexDirection(.column)
          alignItems(.flexStart)
          gap(spacing8)
          width(perc(100))
        }
        descendant(".verify-mfa-label") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeXSmall12)
          fontWeight(fontWeightNormal)
          textTransform(.uppercase)
          letterSpacing(px(0.5))
          color(colorSubtle)
        }
        descendant(".verify-mfa-input") {
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
        descendant(".verify-mfa-submit-container") { width(perc(100)) }
        descendant(".verify-mfa-footer") {
          borderTop(borderWidthBase, borderStyleBase, borderColorBase)
          paddingTop(spacing24)
        }
        descendant(".verify-mfa-back-link") {
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

  /// Client hydration for ``VerifyMFAView`` (code input UX).
  public class VerifyMFAHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: VerifyMFAHydration?

    public static func hydrateIfPresent() {
      guard document.querySelector(".verify-mfa-view") != nil else { return }
      instance = VerifyMFAHydration()
    }

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
