#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

public struct RegisterView: HTML {
    let token: String
    let errorMessage: String?

    public init(token: String, errorMessage: String? = nil) {
        self.token = token
        self.errorMessage = errorMessage
    }

    public func render(indent: Int = 0) -> String {
        div {
            div {
                h1 { "Create Administrator Account" }
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
                            color(colorError)
                            backgroundColor(backgroundColorErrorSubtle)
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
                            TextInputView(id: "username", name: "username", placeholder: "Enter your username", required: true)
                        }
                    }
                    .style { marginBottom(spacing24) }

                    div {
                        FieldView(id: "email") {
                            "Email Address"
                        } input: {
                            TextInputView(id: "email", name: "email", placeholder: "Enter your email", type: .email, required: true)
                        }
                    }
                    .style { marginBottom(spacing24) }

                    div {
                        FieldView(id: "password") {
                            "Password"
                        } input: {
                            TextInputView(id: "password", name: "password", placeholder: "Choose a strong password", type: .password, required: true)
                        }
                    }
                    .style { marginBottom(spacing32) }

                    ButtonView(label: "Complete Registration", action: .progressive, weight: .primary, type: .submit, fullWidth: true)
                }
                .action("/administrator/register/\(token)")
                .method(.post)
            }
            .style {
                width(perc(100))
                maxWidth(px(400))
                padding(spacing48)
                backgroundColor(backgroundColorBase)
                borderRadius(borderRadiusBase)
                boxShadow(boxShadowLarge)
            }
        }
        .class("register-container")
        .style {
            display(.flex)
            justifyContent(.center)
            alignItems(.center)
            minHeight(vh(100))
            backgroundColor(backgroundColorNeutralSubtle)
            fontFamily(typographyFontSans)
        }
        .render(indent: indent)
    }
}

#endif
