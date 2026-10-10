#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import Foundation
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// MFA enrollment: the QR code for an authenticator app, the shared secret
  /// for one that can't scan, and the form that turns MFA on with the first
  /// code the app shows.
  ///
  /// The body of the page only: set it in the site's own card (its title,
  /// notice and links). The QR code is drawn on the client by
  /// `SetupMFAHydration`, from the qrcodejs script the page loads.
  public struct SetupMFAView: HTMLContent {
    /// TOTP shared secret (base32).
    public let secret: String
    /// Full `otpauth://` URL for QR encoding.
    public let otpauthURL: String
    /// The local path to return to once MFA is on, if any.
    public let redirect: String?

    public init(secret: String, otpauthURL: String, redirect: String? = nil) {
      self.secret = secret
      self.otpauthURL = otpauthURL
      self.redirect = redirect
    }

    public func build() -> DOM.Node {
      let query =
        redirect.flatMap { $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(.init(charactersIn: "-._~/"))) }
        .map { "?redirect=\($0)" } ?? ""
      return div {
        section {
          h2 { "Scan the QR code" }
            .class("setup-mfa-step-title")
          p { "Open an authenticator app, such as 1Password, Google Authenticator or Authy, and scan this code." }
            .class("setup-mfa-step-text")
          // Drawn here by the client; the children it draws are presentational.
          div {}
            .id("setup-mfa-qr-code")
            .class("setup-mfa-qr-code")
            .role(.img)
            .ariaLabel("QR code to scan with an authenticator app")
        }
        .class("setup-mfa-step")

        section {
          h2 { "Or enter the secret" }
            .class("setup-mfa-step-title")
          p { "If the app can't scan the code, enter this secret in it instead." }
            .class("setup-mfa-step-text")
          CopyableCodeView(secret, copyLabel: "Copy secret", class: "setup-mfa-secret")
        }
        .class("setup-mfa-step")

        form {
          FieldView(id: "setup-mfa-code") {
            "Code"
          } description: {
            "The 6-digit code the app shows."
          } input: {
            TextInputView(
              id: "setup-mfa-code", name: "code", placeholder: "Code", required: true, inputMode: .numeric,
              autocomplete: .oneTimeCode, minLength: 6, maxLength: 6, pattern: "[0-9]{6}",
              messages: ConstraintMessages(
                valueMissing: "Enter the code from your app.",
                patternMismatch: "The code is 6 digits.",
                length: "The code is 6 digits."))
          }
          ButtonView(
            label: "Enable MFA", buttonColor: .blue, weight: .solid, size: .medium, type: .submit, fullWidth: true)
        }
        .action("\(baseRoute)/authentication/setup\(query)")
        .method(.post)
        .novalidate()
        .class("setup-mfa-form")
      }
      .class("setup-mfa-view")
      .data("otpauth-url", otpauthURL)
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
        }
        descendant(".setup-mfa-step") {
          display(.flex)
          flexDirection(.column)
          gap(spacing12)
        }
        descendant(".setup-mfa-step-title") {
          margin(0)
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          fontWeight(fontWeightSemiBold)
          lineHeight(lineHeightMedium26)
          color(colorBase)
        }
        descendant(".setup-mfa-step-text") {
          margin(0)
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          lineHeight(lineHeightSmall22)
          color(colorSubtle)
        }
        // The code sits on white whatever the color scheme: a scanner reads
        // dark on light.
        descendant(".setup-mfa-qr-code") {
          alignSelf(.center)
          display(.flex)
          width(.fitContent)
          padding(spacing16)
          backgroundColor(backgroundColorBaseFixed)
          border(borderWidthBase, .solid, borderColorBase)
          borderRadius(borderRadiusBase)
        }
        descendant(".setup-mfa-qr-code img") { display(.block) }
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

  /// Client hydration for ``SetupMFAView``: draws the QR code (the secret
  /// is copied by `CopyableCodeHydration`).
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
      guard let container = document.querySelector(".setup-mfa-view"),
        let otpauthURL = container.getAttribute(data("otpauth-url")),
        let qrCode = container.querySelector(".setup-mfa-qr-code")
      else { return }

      QRCode(qrCode, text: otpauthURL, width: 176, height: 176)
      // qrcodejs titles its element with the text it encodes: the secret,
      // as a tooltip. The element is labeled already.
      qrCode.removeAttribute("title")
    }
  }
#endif
