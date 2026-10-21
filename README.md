# AdminCore, as used in [gnorium.com](https://gnorium.com)

Core functionality for an admin console for Swift-based web applications.

## Documentation

Local DocC:
 
```bash
swift package --disable-sandbox preview-documentation --target AdminCore
swift package --disable-sandbox generate-documentation \
  --target AdminCore \
  --output-path ./Docs \
  --transform-for-static-hosting \
  --hosting-base-path admin-core
```
 
## Features

- **Declarative models** — `ModelAdmin` + `Registry`
- **Form fields** — `FieldConfig` / `FieldType`
- **Pages** — lists, users, database browser, sign-in, MFA
- **Layout** — sidebar + navbar shell
- **WASM hydration** — selection and bulk actions on the client

## Installation

```swift
dependencies: [
  .package(url: "https://github.com/gnorium/admin-core", branch: "main")
]
```

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "AdminCore", package: "admin-core")
  ]
)
```

## Quick start

```swift
import AdminCore

Configuration.shared = Configuration(baseRoute: "/admin-console")

struct ArticleAdmin: ModelAdmin {
  let modelName = "Article"
  let modelNamePlural = "Articles"
  let listFields = ["title", "slug", "status"]

  var editFields: [FieldConfig] {
    [
      .text("title", label: "Title", required: true),
      .slug("slug", label: "Slug", from: "title"),
      .markdown("content", label: "Body"),
    ]
  }
}

Registry.shared.register(ArticleAdmin())
```

> Field factories take the field **name as the first unlabeled argument**  
> (e.g. `.text("title", label: "Title")`, `.slug("slug", label: "Slug", from: "title")` — not `name:` / `sourceField:`).

## Requirements

- Swift 6.2+

## License

Apache License 2.0 — see [LICENSE](LICENSE).

## Related packages

- [artifact-core](https://github.com/gnorium/artifact-core) — IIIF Presentation API v3 types + deep zoom viewer
- [design-tokens](https://github.com/gnorium/design-tokens) — Universal design tokens based on Apple HIG
- [diff-engine](https://github.com/gnorium/diff-engine) — Platform-agnostic character-level diff engine
- [embedded-swift-utilities](https://github.com/gnorium/embedded-swift-utilities) — Utility functions for Embedded Swift environments
- [markdown-utilities](https://github.com/gnorium/markdown-utilities) — Markdown rendering with media attribution support
- [tex-utilities](https://github.com/gnorium/tex-utilities) — TeX formula rendering with locally served KaTeX
- [web-apis](https://github.com/gnorium/web-apis) — Web API implementations for Swift WebAssembly
- [web-builders](https://github.com/gnorium/web-builders) — HTML, CSS, JS, and SVG DSL builders
- [web-components](https://github.com/gnorium/web-components) — Reusable UI components for web applications
- [web-formats](https://github.com/gnorium/web-formats) — Structured data format builders
- [web-security](https://github.com/gnorium/web-security) — Portable security utilities for web applications
- [web-tests](https://github.com/gnorium/web-tests) — Swift browser testing across Chrome and Safari
- [web-types](https://github.com/gnorium/web-types) — Shared web types for web applications
- [xml-utilities](https://github.com/gnorium/xml-utilities) — XML and TEI rendering utilities
