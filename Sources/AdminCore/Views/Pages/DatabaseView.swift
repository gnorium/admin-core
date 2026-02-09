#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// Configuration for DatabaseView
public struct DatabaseViewConfig: Sendable {
	public let title: String
	public let subtitle: String
	public let baseURL: String

	public init(
		title: String = "Database",
		subtitle: String = "Direct access to database tables. Use with caution.",
		baseURL: String = "/admin-console/database"
	) {
		self.title = title
		self.subtitle = subtitle
		self.baseURL = baseURL
	}
}

/// Table information with name and row count
public struct TableDisplayInfo: Sendable {
	public let name: String
	public let rowCount: Int

	public init(name: String, rowCount: Int) {
		self.name = name
		self.rowCount = rowCount
	}
}

/// Generic Database explorer view for admin consoles
/// Displays a grid of database tables with index numbers and navigation
public struct DatabaseView: HTMLProtocol {
	let tables: [TableDisplayInfo]
	let config: DatabaseViewConfig

	public init(
		tables: [TableDisplayInfo],
		config: DatabaseViewConfig = DatabaseViewConfig()
	) {
		self.tables = tables
		self.config = config
	}

	public func render(indent: Int = 0) -> String {
		section {
			// Header
			header {
				h1 { config.title }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeXXXLarge28)
					color(colorBase)
					margin(0)
				}

				p { config.subtitle }
				.style {
					fontFamily(typographyFontSans)
					fontSize(fontSizeSmall14)
					color(colorSubtle)
					margin(0)
				}
			}
			.class("database-header")
			.style {
				display(.flex)
				flexDirection(.column)
				gap(spacing8)
				paddingBottom(spacing32)
				borderBottom(borderWidthBase, .solid, borderColorSubtle)
			}

			// Stats row
			div {
				renderStatBadge("Tables", tables.count)
			}
			.style {
				display(.flex)
				gap(spacing16)
			}

			// Table grid
			div {
				for (index, table) in tables.enumerated() {
					a {
						div {
							div {
								span { "\(index + 1)" }
								.style {
									fontSize(fontSizeSmall14)
									color(colorSubtle)
									fontFamily(typographyFontMono)
									minWidth(px(24))
								}
								span { table.name }
								.style {
									fontWeight(fontWeightNormal)
									fontSize(fontSizeMedium16)
								}
								span { "(\(table.rowCount))" }
								.style {
									fontWeight(fontWeightNormal)
									fontSize(fontSizeMedium16)
									color(colorSubtle)
								}
							}
							.style {
								display(.flex)
								alignItems(.center)
								gap(spacing12)
							}

							span { "\u{2192}" }
							.style {
								color(colorSubtle)
								fontSize(fontSizeMedium16)
								fontFamily(typographyFontMono)
							}
						}
						.style {
							display(.flex)
							justifyContent(.spaceBetween)
							alignItems(.center)
							padding(spacing16, spacing20)
							backgroundColor(backgroundColorBase)
							border(borderWidthBase, .solid, borderColorSubtle)
							borderRadius(borderRadiusBase)
							color(colorBase)
							textDecoration(.none)
							transition("all 0.15s ease")
						}
					}
					.href("\(config.baseURL)/\(table.name)")
					.style {
						textDecoration(.none)
						display(.block)
					}
				}
			}
			.class("tables-grid")
			.style {
				display(.grid)
				gridTemplateColumns("1fr")
				gap(spacing16)
			}
		}
		.class("database-container")
		.style {
			display(.flex)
			flexDirection(.column)
			gap(spacing32)
		}
		.render(indent: indent)
	}

	@HTMLBuilder
	private func renderStatBadge(_ label: String, _ value: Int) -> HTMLProtocol {
		div {
			span { label }
			.style {
				fontSize(fontSizeXSmall12)
				color(colorSubtle)
				textTransform(.uppercase)
				letterSpacing(px(0.5))
				fontWeight(fontWeightBold)
			}
			div { "\(value)" }
			.style {
				fontSize(fontSizeMedium16)
				color(colorBase)
				fontFamily(typographyFontSans)
				fontWeight(fontWeightNormal)
			}
		}
		.style {
			padding(spacing16, spacing24)
			backgroundColor(backgroundColorBase)
			border(borderWidthBase, .solid, borderColorSubtle)
			borderRadius(borderRadiusBase)
		}
	}
}

#endif
