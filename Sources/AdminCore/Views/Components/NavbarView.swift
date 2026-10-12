#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  private let baseRoute = Configuration.shared.baseRoute

  /// Top navigation bar for authenticated admin pages.
  ///
  /// Shows the site name, greeting with `username`, and a sign-out control.
  public struct NavbarView: HTMLContent {
    let siteName: String
    let username: String
    let signOutUrl: String?

    /// Creates a navbar.
    /// - Parameters:
    ///   - siteName: Brand / product name in the bar.
    ///   - username: Display name of the signed-in user.
    ///   - signOutUrl: Sign-out endpoint; defaults to `{baseRoute}/sign-out`.
    public init(
      siteName: String = "Admin Console",
      username: String,
      signOutUrl: String? = nil
    ) {
      self.siteName = siteName
      self.username = username
      self.signOutUrl = signOutUrl ?? "\(Configuration.shared.baseRoute)/sign-out"
    }

    public func build() -> DOM.Node {
      div {
        nav {
          div {
            a { siteName }
              .href(baseRoute)
              .class("navbar-brand")
          }
          .class("navbar-brand-wrapper")

          div {
            div {
              span { "Welcome, " }
                .class("navbar-welcome")
              span { username }
                .class("navbar-username")
            }
            .class("navbar-user-details")

            // Ellipsis settings button: quiet, as every navbar's icon
            // buttons are (user, 2026-10-11).
            EllipsisMenuButtonView(weight: .quiet)
          }
          .class("navbar-actions")
        }
        .class("navbar-view")

        // Ellipsis overlay menu
        EllipsisMenuView {
          // Color Scheme
          div {
            span { "Color Scheme" }
              .class("ellipsis-section-header")

            // Every button in the menu is large (user, 2026-10-12).
            ColorSchemeButtonGroupView(size: .large)
          }
          .class("ellipsis-section")

          // Contrast
          div {
            span { "Contrast" }
              .class("ellipsis-section-header")

            ContrastButtonGroupView(size: .large)
          }
          .class("ellipsis-section")

          if let signOutUrl = signOutUrl {
            div {}
              .class("ellipsis-divider")

            div {
              // A form, never a link: signing out is a POST.
              form {
                ButtonView(
                  label: "Sign Out",
                  icon: IconView(icon: { s in LogOutIconView(size: s) }, size: ButtonView.ButtonSize.large.iconSize),
                  weight: .subtle,
                  size: .large,
                  type: .submit,
                  fullWidth: true,
                  labelFontWeight: fontWeightNormal,
                  contentJustifyContent: .flexStart
                )
              }
              .action(signOutUrl)
              .method(.post)
              .class("ellipsis-menu-link")
            }
            .class("ellipsis-section")
          }
        }
      }
      .class("navbar-wrapper")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
        }
        selector(".navbar-view") {
          backgroundColor(backgroundColorBase)
          padding(spacing16)
          display(.flex)
          justifyContent(.spaceBetween)
          alignItems(.center)
          borderBottom(borderWidthBase, borderStyleBase, borderColorBase)
        }
        selector(".navbar-brand-wrapper") {
          display(.flex)
          alignItems(.center)
        }
        selector(".navbar-brand") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeLarge18)
          fontWeight(fontWeightSemiBold)
          color(colorBase)
          textDecoration(.none)
          letterSpacing(px(0.5))
          textTransform(.uppercase)
        }
        selector(".navbar-actions") {
          display(.flex)
          gap(spacing16)
          alignItems(.center)
        }
        selector(".navbar-user-details") {
          display(.flex)
          alignItems(.center)
          gap(spacing4)
        }
        selector(".navbar-welcome") {
          fontSize(fontSizeMedium16)
          color(colorSubtle)
        }
        selector(".navbar-username") {
          fontSize(fontSizeMedium16)
          fontWeight(600)
          color(colorBase)
        }
        selector(".ellipsis-section") {
          display(.flex)
          flexDirection(.column)
          gap(spacing8)
        }
        selector(".ellipsis-section-header") {
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          fontWeight(fontWeightSemiBold)
          color(colorSubtle)
          letterSpacing(px(0.5))
        }
        selector(".ellipsis-divider") {
          height(px(1))
          backgroundColor(borderColorBase)
        }
        selector(".ellipsis-menu-link") {
          textDecoration(.none)
          width(perc(100))
        }
      }
    }
  }
#endif
