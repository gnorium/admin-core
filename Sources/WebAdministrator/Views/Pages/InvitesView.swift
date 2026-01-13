#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

public struct InvitesView: HTML {
    public struct Invite: Sendable {
        public let id: String
        public let token: String
        public let email: String?
        public let status: String

        public init(id: String, token: String, email: String?, status: String) {
            self.id = id
            self.token = token
            self.email = email
            self.status = status
        }
    }

    let invites: [Invite]

    public init(invites: [Invite]) {
        self.invites = invites
    }

    public func render(indent: Int = 0) -> String {
        div {
            header {
                h1 { "Registration Invites" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(px(24))
                        fontWeight(600)
                        color(colorBase)
                    }
            }
            .style { marginBottom(spacing32) }

            // Generate Invite Form
            div {
                h3 { "Generate New Invite" }
                    .style { 
                        marginBottom(spacing16)
                        fontSize(fontSizeMedium16)
                        fontWeight(600)
                        color(colorBase)
                    }
                
                form {
                    div {
                        div {
                            TextInputView(id: "email", name: "email", placeholder: "Recipient Email (optional)", type: .email)
                        }
                        .style {
                            width(px(320))
                            marginRight(spacing16)
                        }
                        
                        ButtonView(label: "Generate Invite", action: .progressive, weight: .primary, type: .submit)
                    }
                    .style { display(.flex); alignItems(.center) }
                }
                .action("/administrator/invites")
                .method(.post)
            }
            .style {
                padding(spacing32)
                backgroundColor(backgroundColorBase)
                borderRadius(borderRadiusBase)
                border(borderWidthBase, borderStyleBase, borderColorBase)
                marginBottom(spacing40)
            }

            // Invites Table
            TableView(
                captionContent: "Invites list",
                hideCaption: true,
                columns: [
                    .init(id: "email", label: "Email"),
                    .init(id: "token", label: "Token"),
                    .init(id: "status", label: "Status")
                ],
                thStyle: { _ in tableHeaderCSS() },
                tbody: {
                    if invites.isEmpty {
                        tr {
                            td {
                                div { "No invites generated yet" }
                                    .style { textAlign(.center); padding(spacing48); color(colorSubtle) }
                            }
                            .colspan(3)
                        }
                    } else {
                        for invite in invites {
                            tr {
                                td { invite.email ?? "Any" }
                                td { code { invite.token } }
                                td { 
                                    span { invite.status }
                                        .style {
                                            display(.inlineBlock)
                                            padding(px(2), spacing8)
                                            borderRadius(px(4))
                                            fontSize(fontSizeSmall14)
                                            fontWeight(500)
                                            backgroundColor(invite.status == "Used" ? backgroundColorNeutralSubtle : backgroundColorSuccessSubtle)
                                            color(invite.status == "Used" ? colorSubtle : colorSuccess)
                                        }
                                }
                            }
                        .style {
                            tableRowCSS()
                        }
                        }
                    }
                }
            )
        }
        .class("invites-page")
        .render(indent: indent)
    }
}

#endif
