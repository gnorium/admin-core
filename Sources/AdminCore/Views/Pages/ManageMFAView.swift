#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// MFA while it is on: the recovery codes (how many are left, and new ones
  /// in their place) and turning MFA off. Each takes a current code from the
  /// authenticator app: a session left open can do neither alone.
  ///
  /// The body of the page only: set it in the site's own card (its title,
  /// the account, a failed attempt's notice).
  public struct ManageMFAView: HTMLContent {
    /// Unused recovery codes.
    public let remainingRecoveryCodes: Int
    /// How many a new set has.
    public let recoveryCodeCount: Int
    /// The code field's message under Regenerate Recovery Codes, after a refused code.
    public let regenerateError: String?
    /// The code field's message under Turn Off MFA, after a refused code.
    public let disableError: String?

    public init(
      remainingRecoveryCodes: Int, recoveryCodeCount: Int, regenerateError: String? = nil,
      disableError: String? = nil
    ) {
      self.remainingRecoveryCodes = remainingRecoveryCodes
      self.recoveryCodeCount = recoveryCodeCount
      self.regenerateError = regenerateError
      self.disableError = disableError
    }

    public func build() -> DOM.Node {
      div {
        section {
          h2 { "Recovery codes" }
            .class("manage-mfa-section-title")
          p {
            "\(remainingRecoveryCodes) of \(recoveryCodeCount) unused. New codes replace them all: the old ones stop working."
          }
          .class("manage-mfa-section-text")
          form {
            codeField(id: "manage-mfa-regenerate-code", error: regenerateError)
            ButtonView(
              label: "Regenerate Recovery Codes", buttonColor: .gray, weight: .subtle, size: .medium, type: .submit,
              fullWidth: true)
          }
          .action("\(baseRoute)/authentication/regenerate-recovery")
          .method(.post)
          .novalidate()
          .class("manage-mfa-form manage-mfa-regenerate-form")
        }
        .class("manage-mfa-section")

        section {
          h2 { "Turn off MFA" }
            .class("manage-mfa-section-title")
          p {
            "The secret and the recovery codes are deleted, and the console asks you to set MFA up again."
          }
          .class("manage-mfa-section-text")
          form {
            codeField(id: "manage-mfa-code", error: disableError)
            ButtonView(
              label: "Turn Off MFA", buttonColor: .red, weight: .solid, size: .medium, type: .submit,
              fullWidth: true)
          }
          .action("\(baseRoute)/authentication/disable")
          .method(.post)
          .novalidate()
          .class("manage-mfa-form manage-mfa-disable-form")
        }
        .class("manage-mfa-section")
      }
      .class("manage-mfa-view")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
        }
        selector("& .manage-mfa-section") {
          display(.flex)
          flexDirection(.column)
          gap(spacing12)
        }
        selector("& .manage-mfa-section + .manage-mfa-section") {
          paddingBlockStart(spacing24)
          borderBlockStart(borderWidthBase, .solid, borderColorBase)
        }
        descendant(".manage-mfa-form") {
          display(.flex)
          flexDirection(.column)
          gap(spacing16)
        }
        descendant(".manage-mfa-section-title") {
          margin(0)
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          fontWeight(fontWeightSemiBold)
          lineHeight(lineHeightMedium26)
          color(colorBase)
        }
        descendant(".manage-mfa-section-text") {
          margin(0)
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          lineHeight(lineHeightSmall22)
          color(colorSubtle)
        }
      }
    }

    /// The current authenticator code both forms take (a private helper: the
    /// two forms here are its only callers).
    private func codeField(id: String, error: String?) -> DOM.Node {
      FieldView(
        id: id, status: error == nil ? .default : .error, messages: .init(error: error)
      ) {
        "Code"
      } description: {
        "The 6-digit code your authenticator app shows."
      } input: {
        TextInputView(
          id: id, name: "code", placeholder: "Code", status: error == nil ? .default : .error, required: true,
          inputMode: .numeric, autocomplete: .oneTimeCode, minLength: 6, maxLength: 6, pattern: "[0-9]{6}",
          messages: ConstraintMessages(
            valueMissing: "Enter the code from your app.",
            patternMismatch: "The code is 6 digits.",
            length: "The code is 6 digits."))
      }
      .build()
    }
  }
#endif
