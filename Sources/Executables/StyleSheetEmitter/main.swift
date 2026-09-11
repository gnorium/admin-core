import CSSBuilder
import Foundation
import AdminCore

@main
struct StyleSheetEmitter {
  static func main() throws {
    let args = CommandLine.arguments
    let publicDir: String
    if let i = args.firstIndex(of: "--public-dir"), i + 1 < args.count {
      publicDir = args[i + 1]
    } else {
      publicDir = "Public"
    }
    StaticStyleSheetEmitter.begin(publicDirectory: publicDir)
    // AdminCore catalogue — import AdminCore views to warm their style sheets.
    // Add representative instances as needed; one per owner is enough now that
    // variants use data-attributes.
    // Example: _ = AdminConsoleDashboardView(...).build()
    let paths = StaticStyleSheetEmitter.finish()
    guard !paths.isEmpty else { throw E.missing }
    for p in paths { print("Emitted /\(p)") }
  }
  enum E: Error { case missing }
}
