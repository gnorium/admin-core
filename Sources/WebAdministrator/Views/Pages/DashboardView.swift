#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Dashboard content component for administrator panel.
/// Use with WebAdministrator.LayoutView for the full page.
public struct DashboardView: HTML {
	public struct Article: Sendable {
		public let id: String
		public let title: String
		public let slug: String
		public let published: Bool
		public let createdAt: String
		public let updatedAt: String

		public init(
			id: String,
			title: String,
			slug: String,
			published: Bool,
			createdAt: String,
			updatedAt: String
		) {
			self.id = id
			self.title = title
			self.slug = slug
			self.published = published
			self.createdAt = createdAt
			self.updatedAt = updatedAt
		}
	}

	let articles: [Article]
	let contentPath: String

	public init(articles: [Article], contentPath: String = "articles") {
		self.articles = articles
		self.contentPath = contentPath
	}

	public func render(indent: Int = 0) -> String {
		div {
			// Header
			header {
				h1 { "Select Article to change" }
					.style {
						fontFamily(typographyFontSans)
						fontSize(px(24))
						fontWeight(600)
						color(colorBase)
					}

				a {
                    ButtonView(label: "Add Article", action: .progressive, weight: .primary, size: .large)
                }
                .href("/administrator/\(contentPath)/new")
                .style {
                    textDecoration(.none)
                }
			}
			.style {
				display(.flex)
				justifyContent(.spaceBetween)
				alignItems(.center)
				marginBottom(spacing32)
			}

			// Articles table or empty state
            TableView(
                captionContent: "Articles list",
                hideCaption: true,
                columns: [
                    .init(id: "title", label: "Title", sortable: true),
                    .init(id: "slug", label: "Slug"),
                    .init(id: "status", label: "Status"),
                    .init(id: "created", label: "Created"),
                    .init(id: "updated", label: "Updated"),
                    .init(id: "actions", label: "Actions", align: .end)
                ],
                thStyle: { _ in tableHeaderCSS() },
                class: "dashboard-table",
                tbody: {
                    if articles.isEmpty {
                        tr {
                            td {
                                div {
                                    div { "No content yet" }
                                        .style {
                                            fontSize(fontSizeLarge18)
                                            fontWeight(600)
                                            marginBottom(spacing8)
                                        }
                                    div { "Create your first article to get started" }
                                }
                                .style {
                                    textAlign(.center)
                                    padding(spacing64, spacing24)
                                    color(colorSubtle)
                                }
                            }
                            .colspan(6)
                        }
                    } else {
                        for article in articles {
                            tr {
                                td { article.title }
                                td { code { article.slug } }
                                td {
                                    span { article.published ? "Published" : "Draft" }
                                    .style {
                                        display(.inlineBlock)
                                        padding(px(4), spacing8)
                                        fontSize(fontSizeSmall14)
                                        borderRadius(px(4))
                                        backgroundColor(article.published ? backgroundColorSuccessSubtle : backgroundColorWarningSubtle)
                                        color(article.published ? colorSuccess : colorWarning)
                                        fontWeight(500)
                                    }
                                }
                                td { article.createdAt }
                                td { article.updatedAt }
                                td {
                                    div {
                                        a { ButtonView(label: "Edit", weight: .quiet, size: .small) }
                                            .href("/administrator/\(contentPath)/\(article.id)/edit")
                                            .style { textDecoration(.none) }

                                        a { ButtonView(label: "View", weight: .quiet, size: .small) }
                                            .href("/\(contentPath)/\(article.slug)")
                                            .target(.blank)
                                            .style { textDecoration(.none) }

                                        a { 
                                            ButtonView(label: "Delete", action: .destructive, weight: .quiet, size: .small) 
                                        }
                                        .class("dashboard-delete-action")
                                        .href("/administrator/\(contentPath)/\(article.id)/delete")
                                        .style { textDecoration(.none) }
                                    }
                                    .style {
                                        display(.flex)
                                        gap(spacing4)
                                        justifyContent(.flexEnd)
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
		.class("dashboard-view")
		.render(indent: indent)
	}
}

#endif

#if os(WASI)

import WebAPIs
import EmbeddedSwiftUtilities

public class DashboardHydration: @unchecked Sendable {
	private var deleteLinks: [Element] = []

	public init() {
		hydrateDeleteActions()
	}

	public func hydrate() {
		hydrateDeleteActions()
	}

	private func hydrateDeleteActions() {
		let links = document.querySelectorAll(".dashboard-delete-action")

		for link in links {
			deleteLinks.append(link)
			_ = link.on(.click) { event in
				let confirmed = globalThis.confirm("Are you sure you want to delete this?")
				if !confirmed {
					event.preventDefault()
				}
			}
		}
	}
}

#endif
