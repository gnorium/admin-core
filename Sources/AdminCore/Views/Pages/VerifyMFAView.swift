#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// The MFA step after a password sign-in: the code from the authenticator
  /// app, or, when the app is lost, one of the recovery codes (each works
  /// once).
  ///
  /// The body of the page only: set it in the site's own card (its title,
  /// the account it verifies, a failed attempt's notice).
  public struct VerifyMFAView: HTMLContent {
    /// The local path to return to once verified, if any.
    public let redirect: String?

    public init(redirect: String? = nil) {
      self.redirect = redirect
    }

    public func build() -> DOM.Node {
      div {
        form {
          if let redirect {
            input()
              .type(.hidden)
              .name("redirect")
              .value(redirect)
          }
          FieldView(id: "verify-mfa-code") {
            "Code"
          } description: {
            "The 6-digit code your authenticator app shows."
          } input: {
            TextInputView(
              id: "verify-mfa-code", name: "code", placeholder: "Code", required: true, inputMode: .numeric,
              autocomplete: .oneTimeCode, minLength: 6, maxLength: 6, pattern: "[0-9]{6}",
              messages: ConstraintMessages(
                valueMissing: "Enter the code from your app.",
                patternMismatch: "The code is 6 digits.",
                length: "The code is 6 digits."))
          }
          ButtonView(
            label: "Verify", buttonColor: .blue, weight: .solid, size: .medium, type: .submit, fullWidth: true)
        }
        .action("\(baseRoute)/mfa/verify")
        .method(.post)
        .novalidate()
        .class("verify-mfa-form")

        form {
          if let redirect {
            input()
              .type(.hidden)
              .name("redirect")
              .value(redirect)
          }
          FieldView(id: "verify-mfa-recovery-code") {
            "Recovery code"
          } description: {
            "If your app is lost: one of the codes you saved when you turned MFA on. Each works once."
          } input: {
            TextInputView(
              id: "verify-mfa-recovery-code", name: "recoveryCode", placeholder: "Recovery code", required: true,
              autocomplete: .off, minLength: 8, maxLength: 9, pattern: "[A-Za-z0-9]{4}-?[A-Za-z0-9]{4}",
              messages: ConstraintMessages(
                valueMissing: "Enter a recovery code.",
                patternMismatch: "A recovery code is 8 letters and digits, like ABCD-EFGH.",
                length: "A recovery code is 8 letters and digits, like ABCD-EFGH."))
          }
          ButtonView(
            label: "Use Recovery Code", buttonColor: .gray, weight: .subtle, size: .medium, type: .submit,
            fullWidth: true)
        }
        .action("\(baseRoute)/mfa/verify")
        .method(.post)
        .novalidate()
        .class("verify-mfa-recovery-form")
      }
      .class("verify-mfa-view")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
        }
        selector("& .verify-mfa-form", "& .verify-mfa-recovery-form") {
          display(.flex)
          flexDirection(.column)
          gap(spacing16)
        }
        descendant(".verify-mfa-recovery-form") {
          paddingBlockStart(spacing24)
          borderBlockStart(borderWidthBase, .solid, borderColorBase)
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

  /// Client hydration for ``VerifyMFAView``: the code field takes the focus,
  /// since it is all the page asks for.
  public class VerifyMFAHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: VerifyMFAHydration?

    public static func hydrateIfPresent() {
      guard document.querySelector(".verify-mfa-view") != nil else { return }
      instance = VerifyMFAHydration()
    }

    public init() {
      document.getElementById("verify-mfa-code")?.focus()
    }
  }
#endif
