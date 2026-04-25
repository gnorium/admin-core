#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  public struct RegisterView: HTMLContent {
    let token: String
    let errorMessage: String?

    public init(token: String, errorMessage: String? = nil) {
      self.token = token
      self.errorMessage = errorMessage
    }

    public func render() -> Node {
      div {
        div {
          h1 { "Create Admin Account" }
            .style {
              fontSize(fontSizeXXLarge24)
              marginBottom(spacing32)
              textAlign(.center)
              fontFamily(typographyFontSans)
              fontWeight(600)
              color(colorBase)
            }

          if let error = errorMessage {
            div { error }
              .style {
                color(colorRed)
                backgroundColor(backgroundColorRedSubtle)
                padding(spacing12, spacing16)
                borderRadius(borderRadiusBase)
                marginBottom(spacing24)
                textAlign(.center)
                fontSize(fontSizeSmall14)
                fontWeight(500)
              }
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
            .style { marginBottom(spacing24) }

            div {
              FieldView(id: "email") {
                "Email Address"
              } input: {
                TextInputView(
                  id: "email", name: "email", placeholder: "Email address", type: .email,
                  required: true)
              }
            }
            .style { marginBottom(spacing24) }

            div {
              FieldView(id: "password") {
                "Password"
              } input: {
                TextInputView(
                  id: "password", name: "password", placeholder: "Choose a strong password",
                  type: .password, required: true)
              }
            }
            .style { marginBottom(spacing32) }

            ButtonView(
              label: "Complete Registration", buttonColor: .blue, weight: .solid, type: .submit,
              fullWidth: true)
          }
          .action("\(baseRoute)/register/\(token)")
          .method(.post)
        }
        .style {
          width(perc(100))
          maxWidth(px(480))
          padding(spacing48)
          backgroundColor(backgroundColorBase)
          borderRadius(borderRadiusBase)
          boxShadow(boxShadowLarge)
        }
      }
      .class("register-view")
      .style {
        display(.flex)
        justifyContent(.center)
        alignItems(.center)
        backgroundColor(backgroundColorNeutralSubtle)
        fontFamily(typographyFontSans)
      }

    }
  }
#endif
