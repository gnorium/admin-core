# AdminCore, as used in [gnorium.com](https://gnorium.com)

Core functionality for an admin console for Swift-based web applications.

## Overview

AdminCore provides a structured, type-safe API for defining and rendering administrative interfaces in Swift. It allows developers to register models using the `ModelAdmin` protocol and automatically generates dashboards, forms, and editors.

## Features

- **Declarative Configuration**: Define admin interfaces using the `ModelAdmin` protocol.
- **Pre-built Views**: Ready-to-use components for dashboards, login, and markdown editing.
- **Interactivity**: Built-in WebAssembly (WASM) hydration for client-side behaviors.
- **Integration**: Seamlessly works with `HTMLBuilder`, `CSSBuilder`, and `DesignTokens`.

## Installation

### Swift Package Manager

Add AdminCore to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/gnorium/admin-core", branch: "main")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "AdminCore", package: "admin-core")
    ]
)
```

## Usage

```swift
import AdminCore

struct ArticleAdmin: ModelAdmin {
    let modelName = "Article"
    let modelNamePlural = "Articles"
    let listFields = ["title", "slug", "status", "createdAt"]
    
    var editFields: [FieldConfig] {
        [
            .text(name: "title", label: "Title"),
            .slug(name: "slug", label: "Slug", sourceField: "title"),
            .markdown(name: "content", label: "Body Content")
        ]
    }
}

// In your application logic:
Registry.shared.register(ArticleAdmin())
```

## Requirements

- Swift 6.2+

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details

## Contributing

Contributions welcome! Please open an issue or submit a pull request.

## Related Packages

- [design-tokens](https://github.com/gnorium/design-tokens) - Universal design tokens based on Apple HIG
- [diff-engine](https://github.com/gnorium/diff-engine) - Platform-agnostic character-level diff engine
- [embedded-swift-utilities](https://github.com/gnorium/embedded-swift-utilities) - Utility functions for Embedded Swift environments
- [markdown-utilities](https://github.com/gnorium/markdown-utilities) - Markdown rendering with media attribution support
- [web-apis](https://github.com/gnorium/web-apis) - Web API implementations for Swift WebAssembly
- [web-builders](https://github.com/gnorium/web-builders) - HTML, CSS, JS, and SVG DSL builders
- [web-components](https://github.com/gnorium/web-components) - Reusable UI components for web applications
- [web-formats](https://github.com/gnorium/web-formats) - Structured data format builders
- [web-security](https://github.com/gnorium/web-security) - Portable security utilities for web applications
- [web-types](https://github.com/gnorium/web-types) - Shared web types and design tokens
