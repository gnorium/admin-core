# Models and Registry

How AdminCore decides what appears in the console: one ``ModelAdmin`` per model, registered once, resolved by URL path.

## ModelAdmin

A ``ModelAdmin`` is a throwaway description of how a model is listed and edited — not the database row itself. Implement it for each entity you manage:

```swift
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
```

| Requirement | Role |
| --- | --- |
| `modelName` / `modelNamePlural` | Copy in headers and empty states |
| `listFields` | Columns on ``IndexView`` |
| `editFields` | Controls on create/edit forms |
| `urlPath` | Route segment under ``Configuration/baseRoute`` (default from plural name) |

Defaults exist for search fields, sort, page size, and column headers — override only what you need.

## Registry

``Registry`` is a process-wide map from `urlPath` → type-erased ``AnyModelAdmin``:

```swift
Registry.shared.register(ArticleAdmin())

let admin = Registry.shared.admin(for: "articles")
let all = Registry.shared.allAdmins()  // sorted by plural name
```

Register at application startup before handling admin routes. Routing code loads the admin by path, maps storage into ``ListRow`` / ``FormData``, and passes that into views.

## Type erasure

``AnyModelAdmin`` stores the same properties as ``ModelAdmin`` so heterogeneous admins can live in one dictionary. Views take `AnyModelAdmin`, not a generic `T: ModelAdmin`.

## Mental model

```
ModelAdmin  →  describe columns + form fields
Registry    →  find admin by URL path
ListRow     →  one table row of string values
IndexView   →  render the table
```

See also <doc:FieldConfigs> and <doc:GettingStarted>.
