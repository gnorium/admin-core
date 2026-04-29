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
    let signOutUrl: String?

    public init(
      siteName: String = "Admin Console",
      username: String,
      signOutUrl: String? = nil
    ) {
      self.siteName = siteName
      self.username = username
      self.signOutUrl = signOutUrl ?? "\(Configuration.shared.baseRoute)/sign-out"
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

          if let signOutUrl = signOutUrl {
            div {}
              .class("ellipsis-divider")
              .style { EllipsisMenuView.dividerCSS() }

            div {
              a {
                ButtonView(
                  label: "Sign Out",
                  icon: IconView(icon: { s in LogOutIconView(width: s, height: s) }, size: .medium),
                  weight: .subtle,
                  size: .large,
                  fullWidth: true,
                  labelFontWeight: fontWeightNormal,
                  contentJustifyContent: .flexStart
                )
              }
              .href(signOutUrl)
              .class("ellipsis-menu-link")
              .style {
                textDecoration(.none)
                width(perc(100))
              }
            }
            .class("ellipsis-section")
            .style { EllipsisMenuView.sectionCSS() }
          }
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
