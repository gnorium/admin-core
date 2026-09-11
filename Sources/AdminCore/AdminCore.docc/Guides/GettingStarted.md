# Getting Started

Build a minimal admin surface: configure routes, register a model, and render a list page.

## Install

Add AdminCore with Swift Package Manager:

```swift
dependencies: [
  .package(url: "https://github.com/gnorium/admin-core", branch: "main")
]
```

```swift
.target(
  name: "YourServer",
  dependencies: [
    .product(name: "AdminCore", package: "admin-core")
  ]
)
```

## Configure the base route

Set ``Configuration`` before rendering views so links resolve under your mount path:

```swift
import AdminCore

Configuration.shared = Configuration(baseRoute: "/admin-console")
```

## Register a model

Implement ``ModelAdmin`` and register it once at startup:

```swift
struct ArticleAdmin: ModelAdmin {
  let modelName = "Article"
  let modelNamePlural = "Articles"
  let listFields = ["title", "slug", "status", "createdAt"]

  var editFields: [FieldConfig] {
    [
      .text("title", label: "Title", required: true),
      .slug("slug", label: "Slug", from: "title"),
      .select(
        "status",
        label: "Status",
        options: [("draft", "Draft"), ("published", "Published")]
      ),
      .markdown("content", label: "Body"),
    ]
  }
}

Registry.shared.register(ArticleAdmin())
```

Factory methods on ``FieldConfig`` use a leading name parameter (not `name:` labels):

```swift
// Correct
FieldConfig.text("title", label: "Title", required: true)
FieldConfig.slug("slug", label: "Slug", from: "title")
FieldConfig.slug("slug", label: "Slug", from: "title", required: true, helpText: "URL path segment")

// Incorrect (will not compile)
// FieldConfig.text(name: "title", label: "Title")
// FieldConfig.slug(name: "slug", sourceField: "title")
```

## Render a list page

Map your storage into ``ListRow`` values and pass a type-erased admin:

```swift
let admin = Registry.shared.admin(for: "articles")!
let rows: [ListRow] = articles.map { article in
  ListRow(
    id: article.id,
    values: [
      "title": article.title,
      "slug": article.slug,
      "status": article.status,
      "createdAt": article.createdAtDescription,
    ]
  )
}

IndexView(admin: admin, rows: rows)
```

Wrap with ``LayoutView`` for sidebar and navbar:

```swift
LayoutView(username: currentUser.name, showNavbar: true, showSidebar: true) {
  IndexView(admin: admin, rows: rows)
}
```

## Client hydration

On WebAssembly (`CLIENT`), instantiate the matching hydration type so bulk actions and selection work. For example, `IndexHydration` wires table selection to the Edit / Delete controls rendered by ``IndexView``.

See <doc:ClientHydration> for the full list of hydration types.

## Next steps

- Explore ``DatabaseView`` and ``TableBrowserView`` for raw table access
- Use ``UsersView`` for account management UI
- Wire ``SignInView`` / MFA views into your auth routes
