#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// Navbar component for admin pages.
  /// Shows the site name, username, and sign out link.
  private let baseRoute = Configuration.shared.baseRoute

  public struct NavbarView: HTMLContent {
    let siteName: String
    let username: String

    public init(siteName: String = "Admin Console", username: String) {
      self.siteName = siteName
      self.username = username
    }

    public func render() -> Node {
      div {
        nav {
          div {
            a { siteName }
              .href(baseRoute)
              .style {
                fontFamily(typographyFontSans)
                fontSize(fontSizeLarge18)
                fontWeight(700)
                color(colorBase)
                textDecoration(.none)
                letterSpacing(px(0.5))
                textTransform(.uppercase)
              }
          }
          .style {
            display(.flex)
            alignItems(.center)
          }

          div {
            div {
              span { "Welcome, " }
                .style {
                  fontSize(fontSizeSmall14)
                  color(colorSubtle)
                }
              span { username }
                .style {
                  fontSize(fontSizeSmall14)
                  fontWeight(600)
                  color(colorBase)
                }
            }
            .style {
              display(.flex)
              alignItems(.center)
              gap(spacing4)
            }

            // Ellipsis settings button
            EllipsisMenuButtonView()

            ButtonView(
              label: "Sign Out", weight: .quiet, size: .large, url: "\(baseRoute)/sign-out")
          }
          .style {
            display(.flex)
            gap(spacing16)
            alignItems(.center)
          }
        }
        .class("navbar-view")
        .style {
          backgroundColor(backgroundColorBase)
          padding(spacing16, spacing32)
          display(.flex)
          justifyContent(.spaceBetween)
          alignItems(.center)
          borderBottom(borderWidthBase, borderStyleBase, borderColorSubtle)
        }

        // Ellipsis overlay menu
        EllipsisMenuView {
          // Color Scheme
          div {
            span { "Color Scheme" }
              .class("ellipsis-section-header")
              .style { EllipsisMenuView.sectionHeaderCSS() }

            ColorSchemeButtonGroupView()
          }
          .class("ellipsis-section")
          .style { EllipsisMenuView.sectionCSS() }

          // Contrast
          div {
            span { "Contrast" }
              .class("ellipsis-section-header")
              .style { EllipsisMenuView.sectionHeaderCSS() }

            ContrastButtonGroupView()
          }
          .class("ellipsis-section")
          .style { EllipsisMenuView.sectionCSS() }
        }
      }
      .class("navbar-wrapper")
      .style {
        display(.flex)
        flexDirection(.column)
      }
    }
  }
#endif
