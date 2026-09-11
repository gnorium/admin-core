#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// Invite-token registration form for creating an admin account.
  public struct RegisterView: HTMLContent {
    let token: String
    let errorMessage: String?

    /// - Parameters:
    ///   - token: Invite token submitted with the form.
    ///   - errorMessage: Optional error banner text.
    public init(token: String, errorMessage: String? = nil) {
      self.token = token
      self.errorMessage = errorMessage
    }

    public func build() -> DOM.Node {
      div {
        div {
          h1 { "Create Admin Account" }
            .class("register-title")

          if let error = errorMessage {
            div { error }
              .class("register-error")
          }

          form {
            div {
              FieldView(id: "username") {
                "Username"
              } input: {
                TextInputView(
                  id: "username", name: "username", placeholder: "Username", required: true)
              }
            }
            .class("register-field register-field-standard")

            div {
              FieldView(id: "email") {
                "Email Address"
              } input: {
                TextInputView(
                  id: "email", name: "email", placeholder: "Email address", type: .email,
                  required: true)
              }
            }
            .class("register-field register-field-standard")

            div {
              FieldView(id: "password") {
                "Password"
              } input: {
                TextInputView(
                  id: "password", name: "password", placeholder: "Choose a strong password",
                  type: .password, required: true)
              }
            }
            .class("register-field register-field-last")

            ButtonView(
              label: "Complete Registration", buttonColor: .blue, weight: .solid, type: .submit,
              fullWidth: true)
          }
          .action("\(baseRoute)/register/\(token)")
          .method(.post)
        }
        .class("register-card")
      }
      .class("register-view")
      .style {
        selector("&") {
          display(.flex)
          justifyContent(.center)
          alignItems(.center)
          backgroundColor(backgroundColorNeutralSubtle)
          fontFamily(typographyFontSans)
        }
        descendant(".register-card") {
          width(perc(100))
          maxWidth(px(480))
          padding(spacing48)
          backgroundColor(backgroundColorBase)
          borderRadius(borderRadiusBase)
          boxShadow(boxShadowLarge)
        }
        descendant(".register-title") {
          fontSize(fontSizeXXLarge24)
          marginBottom(spacing32)
          textAlign(.center)
          fontFamily(typographyFontSans)
          fontWeight(600)
          color(colorBase)
        }
        descendant(".register-error") {
          color(colorRed)
          backgroundColor(backgroundColorRedSubtle)
          padding(spacing12, spacing16)
          borderRadius(borderRadiusBase)
          marginBottom(spacing24)
          textAlign(.center)
          fontSize(fontSizeSmall14)
          fontWeight(500)
        }
        descendant(".register-field-standard") { marginBottom(spacing24) }
        descendant(".register-field-last") { marginBottom(spacing32) }
      }

    }
  }
#endif
