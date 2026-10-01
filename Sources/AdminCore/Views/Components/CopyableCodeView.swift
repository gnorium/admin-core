#if SERVER
  import CSSBuilder
  import DesignTokens
  import DOMBuilder
  import HTMLBuilder
  import WebComponents
  import WebTypes

  /// Text to copy by hand into another app (an MFA secret, recovery codes):
  /// a CodeView in a bordered box, with a copy button that shows a check for
  /// two seconds once it has copied. `CopyableCodeHydration` copies.
  public struct CopyableCodeView: HTMLContent {
    let text: String
    let copyLabel: String
    let `class`: String

    /// - Parameters:
    ///   - text: What is shown and copied; lines stay lines.
    ///   - copyLabel: The copy button's accessible name ("Copy secret").
    ///   - class: The page's own class for this box, beside the view's.
    public init(_ text: String, copyLabel: String, class: String = "") {
      self.text = text
      self.copyLabel = copyLabel
      self.class = `class`
    }

    public func build() -> DOM.Node {
      div {
        CodeView(text, language: "plaintext", showLineNumbers: false)
        ButtonView(
          weight: .quiet, iconOnly: true, ariaLabel: copyLabel, class: "copyable-code-copy",
          data: [("copied", "false"), ("copy-label", copyLabel)]
        ) {
          span { CopyIconView(size: sizeIconSmall) }
            .class("copyable-code-copy-icon")
          span { CheckIconView(size: sizeIconSmall) }
            .class("copyable-code-copied-icon")
        }
      }
      .class(`class`.isEmpty ? "copyable-code-view" : "copyable-code-view \(`class`)")
      .style {
        selector("&") {
          display(.flex)
          alignItems(.center)
          justifyContent(.spaceBetween)
          gap(spacing8)
          paddingBlock(spacing4)
          paddingInlineStart(spacing12)
          paddingInlineEnd(spacing4)
          border(borderWidthBase, .solid, borderColorBase)
          borderRadius(borderRadiusBase)
        }
        descendant(".code-view") {
          minWidth(0)
          overflowX(.auto)
        }
        descendant(".copyable-code-copied-icon") { display(.none) }
        descendant(".copyable-code-copy[data-copied='true'] .copyable-code-copy-icon") { display(.none) }
        descendant(".copyable-code-copy[data-copied='true'] .copyable-code-copied-icon") { display(.flex) }
      }
    }
  }
#endif

#if CLIENT
  import DOMBuilder
  import EmbeddedSwiftUtilities
  import HTMLBuilder
  import WebAPIs
  import WebTypes

  /// Client hydration for every ``CopyableCodeView`` on the page.
  public class CopyableCodeHydration: @unchecked Sendable {
    public static nonisolated(unsafe) var instance: CopyableCodeHydration?

    public static func hydrateIfPresent() {
      guard document.querySelector(".copyable-code-view") != nil else { return }
      instance = CopyableCodeHydration()
    }

    public init() {
      for view in document.querySelectorAll(".copyable-code-view") {
        guard let button = view.querySelector(".copyable-code-copy"),
          let code = view.querySelector("code")
        else { continue }
        let label = button.getAttribute(data("copy-label")) ?? "Copy"
        _ = button.addEventListener(.click) { (event: Event) in
          window.navigator.clipboard.writeText(from: code)
          button.setAttribute(data("copied"), true)
          button.setAttribute("aria-label", "Copied")
          _ = window.setTimeout(2000) {
            button.setAttribute(data("copied"), false)
            button.setAttribute("aria-label", label)
          }
        }
      }
    }
  }
#endif
