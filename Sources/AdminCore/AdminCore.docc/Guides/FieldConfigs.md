# Field Configs

``FieldConfig`` describes one control on a create/edit form. Prefer factory methods on ``FieldConfig`` over the long memberwise initializer.

## Factory style

The **name** is always the first unlabeled argument (not `name:`):

```swift
// Correct
FieldConfig.text("title", label: "Title", required: true)
FieldConfig.slug("slug", label: "Slug", from: "title")
FieldConfig.select(
  "status",
  label: "Status",
  options: [("draft", "Draft"), ("published", "Published")]
)

// Incorrect
// FieldConfig.text(name: "title", label: "Title")
// FieldConfig.slug(name: "slug", sourceField: "title")
```

## Common factories

| Factory | Use |
| --- | --- |
| ``FieldConfig/text(_:label:required:placeholder:helpText:)`` | Single-line text |
| ``FieldConfig/textarea(_:label:required:placeholder:helpText:)`` | Multi-line text |
| ``FieldConfig/checkbox(_:label:defaultValue:)`` | Boolean |
| ``FieldConfig/select(_:label:options:required:)`` | Dropdown |
| ``FieldConfig/slug(_:label:from:required:placeholder:helpText:)`` | URL slug from another field |
| ``FieldConfig/markdown(_:label:required:)`` | Markdown body |
| ``FieldConfig/tags(_:label:helpText:)`` | Tag list |
| ``FieldConfig/hidden(_:value:)`` | Hidden fixed value |

## Slug fields

```swift
.slug("slug", label: "Slug", from: "title", required: true, helpText: "URL path segment")
```

- Call site uses **`from:`** for the source field name.
- In DocC / symbol docs the parameter appears as **`source`** (internal name).
- ``FieldConfig/slugSource`` holds that source field for the form renderer.

## FieldType

``FieldType`` is the enum behind each control (`.text`, `.select`, `.markdown`, …). Factories set it for you; use the memberwise ``FieldConfig/init(name:label:fieldType:required:helpText:placeholder:options:slugSource:defaultValue:readOnly:)`` only for uncommon cases.

## Form data

Submitted values travel as strings in ``FormData``:

- `values` — single-value fields  
- `multiValues` — multi-value fields (e.g. tags)  
- `id` — set when editing, `nil` when creating  

See <doc:ModelsAndRegistry> for where `editFields` plugs into ``ModelAdmin``.
