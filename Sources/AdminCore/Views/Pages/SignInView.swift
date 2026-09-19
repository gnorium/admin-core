#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// Username/password sign-in form for the admin console.
  ///
  /// Compose with ``AdminCoreLayoutView`` for the full page chrome.
  public struct SignInView: HTMLContent {
    let errorMessage: String?

    /// - Parameter errorMessage: Optional error banner text.
    public init(errorMessage: String? = nil) {
      self.errorMessage = errorMessage
    }

    public func build() -> DOM.Node {
      div {
        div {
          div {
            h1 { "Sign In" }
              .class("admin-sign-in-title")

            p { "Sign in to manage content" }
              .class("admin-sign-in-subtitle")
          }
          .class("admin-sign-in-heading")

          if let error = errorMessage, !error.isEmpty {
            div {
              p { error }
                .class("admin-sign-in-error-message")
            }
            .class("error-banner")
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

            div {
              FieldView(id: "password") {
                "Password"
              } input: {
                TextInputView(
                  id: "password", name: "password", placeholder: "Password", type: .password,
                  required: true)
              }
            }

            ButtonView(
              label: "Sign In", buttonColor: .blue, weight: .solid, size: .medium, type: .submit,
              fullWidth: true)

            div {
              a { "← Back to Site" }
                .href("/")
                .class("admin-sign-in-back-link")
            }
            .class("admin-sign-in-back")
          }
          .action("\(baseRoute)/sign-in")
          .method(.post)
          .class("admin-sign-in-form")
        }
        .class("admin-sign-in-card")
      }
      .class("sign-in-view")
      .style {
        selector("&") {
          display(.flex)
          justifyContent(.center)
          alignItems(.center)
          flex(1)
        }
        descendant(".admin-sign-in-card") {
          display(.flex)
          flexDirection(.column)
          gap(spacing32)
          width(perc(100))
          maxWidth(px(480))
          backgroundColor(backgroundColorBase)
          border(borderWidthBase, borderStyleBase, borderColorSubtle)
          borderRadius(borderRadiusBase)
          padding(spacing40)
        }
        descendant(".admin-sign-in-heading") {
          display(.flex)
          flexDirection(.column)
          gap(spacing12)
          textAlign(.center)
        }
        descendant(".admin-sign-in-title") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeXXXLarge28)
          fontWeight(fontWeightNormal)
          color(colorBase)
          margin(0)
        }
        descendant(".admin-sign-in-subtitle") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          margin(0)
        }
        descendant(".error-banner") {
          backgroundColor(backgroundColorRedSubtle)
          border(borderWidthBase, .solid, borderColorRed)
          borderRadius(borderRadiusBase)
          padding(spacing12, spacing16)
        }
        descendant(".admin-sign-in-error-message") {
          fontFamily(typographyFontSans)
          margin(0)
          fontSize(fontSizeSmall14)
          color(colorRed)
        }
        descendant(".admin-sign-in-form") {
          display(.flex)
          flexDirection(.column)
          gap(spacing24)
        }
        descendant(".admin-sign-in-back") { textAlign(.center) }
        descendant(".admin-sign-in-back-link") {
          display(.inlineBlock)
          fontSize(fontSizeSmall14)
          color(colorSubtle)
          textDecoration(.none)
          fontFamily(typographyFontSans)
          fontWeight(500)
          pseudoClass(.hover) { color(colorBase) }
        }
      }
    }
  }
#endif
