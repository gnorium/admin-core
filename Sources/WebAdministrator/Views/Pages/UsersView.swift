#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

public struct UsersView: HTML {
    public struct User: Sendable {
        public let id: String
        public let username: String
        public let email: String
        public let role: String

        public init(id: String, username: String, email: String, role: String) {
            self.id = id
            self.username = username
            self.email = email
            self.role = role
        }
    }

    let users: [User]

    public init(users: [User]) {
        self.users = users
    }

    public func render(indent: Int = 0) -> String {
        div {
            header {
                h1 { "Administrator Users" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(px(24))
                        fontWeight(600)
                        color(colorBase)
                    }
            }
            .style { marginBottom(spacing32) }

            TableView(
                captionContent: "Users list",
                hideCaption: true,
                columns: [
                    .init(id: "username", label: "Username"),
                    .init(id: "email", label: "Email"),
                    .init(id: "role", label: "Role")
                ],
                thStyle: { _ in tableHeaderCSS() },
                tbody: {
                    for user in users {
                        tr {
                            td { user.username }
                            td { user.email }
                            td { 
                                span { user.role }
                                    .style {
                                        display(.inlineBlock)
                                        padding(px(4), spacing8)
                                        fontSize(fontSizeSmall14)
                                        borderRadius(px(4))
                                        fontWeight(500)
                                        backgroundColor(backgroundColorNeutralSubtle)
                                        color(colorBase)
                                    }
                            }
                        }
                        .style {
                            tableRowCSS()
                        }
                    }
                }
            )
        }
        .class("users-page")
        .render(indent: indent)
    }
}

#endif
