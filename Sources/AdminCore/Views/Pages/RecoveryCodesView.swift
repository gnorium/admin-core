#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import Foundation
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// MFA recovery codes, the one time they are shown: right after MFA is
  /// turned on, or after Regenerate. The codes to copy or download as a text
  /// file, and the way on.
  ///
  /// The body of the page only: set it in the site's own card, whose notice
  /// says to store them now (they are kept only as hashes, and never shown
  /// again).
  public struct RecoveryCodesView: HTMLContent {
    /// The codes, formatted as shown ("ABCD-EFGH").
    public let codes: [String]
    /// Where Continue goes.
    public let continueURL: String

    public init(codes: [String], continueURL: String) {
      self.codes = codes
      self.continueURL = continueURL
    }

    public func build() -> DOM.Node {
      let text = codes.joined(separator: "\n")
      let file =
        "Gnorium recovery codes\nEach code works once, in place of a code from your authenticator app.\n\n\(text)\n"
      let encoded =
        file.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(.init(charactersIn: "-._~"))) ?? ""
      return div {
        p { "Each code signs you in once, in place of a code from your authenticator app, if the app is lost." }
          .class("recovery-codes-text")
        CopyableCodeView(text, copyLabel: "Copy recovery codes", class: "recovery-codes-list")
        div {
          ButtonView(
            label: "Download as text file",
            icon: IconView(icon: { s in DownloadIconView(size: s) }, size: ButtonView.ButtonSize.large.labelIconSize),
            buttonColor: .gray, weight: .subtle, size: .large, url: "data:text/plain;charset=utf-8,\(encoded)",
            fullWidth: true, class: "recovery-codes-download"
          )
          .download("gnorium-recovery-codes.txt")
          ButtonView(
            label: "Continue", buttonColor: .blue, weight: .solid, size: .large, url: continueURL, fullWidth: true,
            class: "recovery-codes-continue")
        }
        .class("recovery-codes-actions")
      }
      .class("recovery-codes-view")
      .style {
        selector("&") {
          display(.flex)
          flexDirection(.column)
          gap(spacing16)
        }
        descendant(".recovery-codes-text") {
          margin(0)
          fontFamily(typographyFontSans)
          fontSize(fontSizeMedium16)
          lineHeight(lineHeightSmall22)
          color(colorSubtle)
        }
        descendant(".recovery-codes-actions") {
          display(.flex)
          flexDirection(.column)
          gap(spacing16)
        }
      }
    }
  }
#endif
