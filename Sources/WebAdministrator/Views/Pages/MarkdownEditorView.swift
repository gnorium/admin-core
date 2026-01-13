#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

public struct MarkdownEditorView: HTML {
	public struct ContentData: Sendable {
		public let id: String?
		public let title: String
		public let slug: String
		public let description: String
		public let content: String
		public let author: String
		public let imageUrl: String?
		public let imageCaption: String?
		public let tags: [String]
		public let published: Bool

		public init(
			id: String? = nil,
			title: String = "",
			slug: String = "",
			description: String = "",
			content: String = "",
			author: String = "",
			imageUrl: String? = nil,
			imageCaption: String? = nil,
			tags: [String] = [],
			published: Bool = false
		) {
			self.id = id
			self.title = title
			self.slug = slug
			self.description = description
			self.content = content
			self.author = author
			self.imageUrl = imageUrl
			self.imageCaption = imageCaption
			self.tags = tags
			self.published = published
		}
	}

	let data: ContentData
	let isNew: Bool
	let contentPath: String

	public init(
		data: ContentData,
		isNew: Bool = true,
		contentPath: String
	) {
		self.data = data
		self.isNew = isNew
		self.contentPath = contentPath
	}

	public func render(indent: Int = 0) -> String {
		// Editor container
		div {
			header {
				h1 { isNew ? "New Content" : "Edit Content" }
					.style {
						fontFamily(typographyFontSans)
						fontSize(px(24))
						fontWeight(600)
						color(colorBase)
						marginBottom(spacing8)
					}

				p { "Write your content in Markdown format" }
					.style {
						fontSize(fontSizeSmall14)
						color(colorSubtle)
					}
			}
			.style {
				marginBottom(spacing32)
			}

			form {
				// Title
				div {
					label { "Title" }
						.for("title")
						.style { formLabelStyle() }

					input()
						.type(.text)
						.id("title")
						.name("title")
						.value(data.title)
						.required(true)
						.placeholder("Title")
						.style { formInputStyle() }
				}
				.style { formGroupStyle() }

				// Slug
				div {
					label { "Slug" }
						.for("slug")
						.style { formLabelStyle() }

					input()
						.type(.text)
						.id("slug")
						.name("slug")
						.value(data.slug)
						.required(true)
						.placeholder("Slug")
						.style { formInputStyle() }
				}
				.style { formGroupStyle() }

				// Description
				div {
					label { "Description" }
						.for("description")
						.style { formLabelStyle() }

					textarea { data.description }
						.id("description")
						.name("description")
						.required(true)
						.placeholder("Description")
						.rows(3)
						.style { formInputStyle() }
				}
				.style { formGroupStyle() }

				// Content (markdown)
				div {
					label { "Content (markdown)" }
						.for("content")
						.style { formLabelStyle() }

					textarea { data.content }
						.id("content")
						.name("content")
						.required(true)
						.placeholder("Your content here")
						.style {
							formInputStyle()
							minHeight(px(400))
							fontFamily(typographyFontMono)
							lineHeight(1.6)
							resize(.vertical)
						}
				}
				.style { formGroupStyle() }

				// Author
				div {
					label { "Author" }
						.for("author")
						.style { formLabelStyle() }

					input()
						.type(.text)
						.id("author")
						.name("author")
						.placeholder("Author")
						.value(data.author)
						.required(true)
						.style { formInputStyle() }
				}
				.style { formGroupStyle() }

				// Image URL (optional)
				div {
					label {
						"Image URL "
						span { "(optional)" }
							.style {
								fontWeight(.normal)
								color(colorSubtle)
							}
					}
					.for("imageUrl")
					.style { formLabelStyle() }

					input()
						.type(.text)
						.id("imageUrl")
						.name("imageUrl")
						.value(data.imageUrl ?? "")
						.placeholder("Image URL")
						.style { formInputStyle() }
				}
				.style { formGroupStyle() }

				// Image Caption (optional)
				div {
					label {
						"Image Caption "
						span { "(optional)" }
							.style {
								fontWeight(.normal)
								color(colorSubtle)
							}
					}
					.for("imageCaption")
					.style { formLabelStyle() }

					input()
						.type(.text)
						.id("imageCaption")
						.name("imageCaption")
						.value(data.imageCaption ?? "")
						.placeholder("Image caption")
						.style { formInputStyle() }
				}
				.style { formGroupStyle() }

				// Tags
				div {
					label {
						"Tags "
						span { "(comma-separated)" }
							.style {
								fontWeight(.normal)
								color(colorSubtle)
							}
					}
					.for("tags")
					.style { formLabelStyle() }

					input()
						.type(.text)
						.id("tags")
						.name("tags")
						.value(data.tags.joined(separator: ", "))
						.placeholder("Tags")
						.style { formInputStyle() }
				}
				.style { formGroupStyle() }

				// Published checkbox
				div {
					label {
						input()
							.type(.checkbox)
							.id("published")
							.name("published")
							.value("true")
							.checked(data.published)
							.style {
								width(px(20))
								height(px(20))
								cursor(.pointer)
							}

						" Published"
					}
					.for("published")
					.style {
						display(.flex)
						alignItems(.center)
						gap(spacing8)
					}

					p { "Only published content will be visible to the public" }
						.style {
							fontSize(fontSizeSmall14)
							color(colorSubtle)
							fontStyle(.italic)
						}
				}
				.style { formGroupStyle() }

				// Actions
				div {
					ButtonView(
						label: isNew ? "Create" : "Update",
						action: .progressive,
						weight: .primary,
						size: .large,
						type: .submit
					)

					a { ButtonView(label: "Cancel", weight: .normal, size: .large) }
						.href("/administrator")
						.style {
							textDecoration(.none)
						}
				}
				.style {
					display(.flex)
					gap(spacing16)
					paddingTop(spacing16)
					borderTop(borderWidthBase, borderStyleBase, borderColorSubtle)
				}
			}
			.action(isNew ? "/administrator/\(contentPath)" : "/administrator/\(contentPath)/\(data.id ?? "")")
			.method(.post)
			.style {
				display(.flex)
				flexDirection(.column)
				gap(spacing24)
			}
		}
		.class("markdown-editor-view")
		.style {
			maxWidth(px(1280))
			margin(0, .auto)
			padding(spacing48, spacing24)
		}
		.render(indent: indent)
	}

	@CSSBuilder
	private func formGroupStyle() -> [any CSS] {
		display(.flex)
		flexDirection(.column)
		gap(spacing8)
	}

	@CSSBuilder
	private func formLabelStyle() -> [any CSS] {
		fontSize(fontSizeMedium16)
		fontWeight(500)
		color(colorBase)
	}

	@CSSBuilder
	private func formInputStyle() -> [any CSS] {
		width(perc(100))
		padding(spacing12, spacing16)
		fontFamily(typographyFontSans)
		fontSize(fontSizeMedium16)
		color(colorBase)
		backgroundColor(backgroundColorBase)
		border(borderWidthBase, borderStyleBase, borderColorBase)
		borderRadius(borderRadiusBase)
	}
}

#endif
