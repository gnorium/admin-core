#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// MFA while it is on: the recovery codes (how many are left, and new ones
  /// in their place) and turning MFA off, which takes a current code from the
  /// authenticator app.
  ///
  /// The body of the page only: set it in the site's own card (its title,
  /// the account, a failed attempt's notice).
  public struct ManageMFAView: HTMLContent {
    /// Unused recovery codes.
    public let remainingRecoveryCodes: Int
    /// How many a new set has.
    public let recoveryCodeCount: Int

    public init(remainingRecoveryCodes: Int, recoveryCodeCount: Int) {
      self.remainingRecoveryCodes = remainingRecoveryCodes
      self.recoveryCodeCount = recoveryCodeCount
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
            ButtonView(
              label: "Regenerate Recovery Codes", buttonColor: .gray, weight: .subtle, size: .medium, type: .submit,
              fullWidth: true)
          }
          .action("\(baseRoute)/mfa/regenerate-recovery")
          .method(.post)
          .class("manage-mfa-regenerate-form")
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
            FieldView(id: "manage-mfa-code") {
              "Code"
            } description: {
              "The 6-digit code your authenticator app shows."
            } input: {
              TextInputView(
                id: "manage-mfa-code", name: "code", placeholder: "Code", required: true, inputMode: .numeric,
                autocomplete: .oneTimeCode, minLength: 6, maxLength: 6, pattern: "[0-9]{6}",
                messages: ConstraintMessages(
                  valueMissing: "Enter the code from your app.",
                  patternMismatch: "The code is 6 digits.",
                  length: "The code is 6 digits."))
            }
            ButtonView(
              label: "Turn Off MFA", buttonColor: .red, weight: .solid, size: .medium, type: .submit,
              fullWidth: true)
          }
          .action("\(baseRoute)/mfa/disable")
          .method(.post)
          .novalidate()
          .class("manage-mfa-disable-form")
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
          borderBlockStart(borderWidthBase, .solid, borderColorSubtle)
        }
        descendant(".manage-mfa-disable-form") {
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
  }
#endif
