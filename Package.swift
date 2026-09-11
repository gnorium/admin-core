// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "admin-core",
  platforms: [.macOS(.v15), .iOS(.v18)],
  products: [
    .library(
      name: "AdminCore",
      targets: ["AdminCore"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.5.0"),
    .package(url: "https://github.com/gnorium/design-tokens", branch: "main"),
    .package(url: "https://github.com/gnorium/embedded-swift-utilities", branch: "main"),
    .package(url: "https://github.com/gnorium/web-apis", branch: "main"),
    .package(url: "https://github.com/gnorium/web-builders", branch: "main"),
    .package(url: "https://github.com/gnorium/web-components", branch: "main"),
    .package(url: "https://github.com/gnorium/web-types", branch: "main"),
  ],
  targets: [
    .executableTarget(
      name: "StyleSheetEmitter",
      dependencies: [
        "AdminCore",
        .product(name: "CSSBuilder", package: "web-builders"),
      ],
      path: "Sources/Executables/StyleSheetEmitter"
    ),
    .target(
      name: "AdminCore",
      dependencies: [
        .product(name: "CSSBuilder", package: "web-builders"),
        .product(name: "DesignTokens", package: "design-tokens"),
        .product(name: "EmbeddedSwiftUtilities", package: "embedded-swift-utilities"),
        .product(name: "HTMLBuilder", package: "web-builders"),
        .product(name: "DOMBuilder", package: "web-builders"),
        .product(name: "CSSOMBuilder", package: "web-builders"),
        .product(name: "JSBuilder", package: "web-builders"),
        .product(name: "WebAPIs", package: "web-apis"),
        .product(name: "WebComponents", package: "web-components"),
        .product(name: "WebTypes", package: "web-types"),
      ],
      path: "Sources/AdminCore",
      swiftSettings: [
        .enableExperimentalFeature("Embedded", .when(platforms: [.wasi])),
        // CLIENT only for WASM — host/server builds must not compile browser APIs
        // (document/window). DocC on macOS is SERVER-only; hydrations are covered in
        // Guides (ClientHydration) as prose, not symbol links.
        .define("CLIENT", .when(platforms: [.wasi])),
        .define("SERVER", .when(platforms: [.macOS, .linux, .windows])),
      ]
    )
  ]
)
