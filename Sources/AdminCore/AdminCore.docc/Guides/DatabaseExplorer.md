# Database Explorer

Raw-table UI for admin consoles: pick a table, browse rows, create / edit / inspect.

## Flow

```
DatabaseView          → grid of tables
TableBrowserView      → paginated rows for one table
TableRowDetailsView   → read-only row
TableRowEditorView    → edit row
TableRowCreatorView   → insert row
```

## DatabaseView

```swift
DatabaseView(
  tables: [
    TableDisplayInfo(name: "users", rowCount: 42),
    TableDisplayInfo(name: "sessions", rowCount: 100),
  ],
  config: DatabaseViewConfig(baseURL: "/admin-console/database")
)
```

``DatabaseViewConfig`` sets title, subtitle, and `baseURL` used for table links.

## TableBrowserView

```swift
TableBrowserView(
  tableName: "users",
  columns: ["id", "email", "role"],
  rows: rows.map { TableRowData(cells: $0) },
  totalCount: total,
  currentPage: page,
  totalPages: pages,
  config: TableBrowserConfig(
    baseURL: "/admin-console/database/users",
    primaryKey: "id",
    editable: true
  )
)
```

``TableBrowserConfig`` controls back navigation, editability, and primary key column. Pair with `TableBrowserHydration` on the client for bulk actions.

## Row pages

| View | Role |
| --- | --- |
| ``TableRowDetailsView`` | Read-only detail |
| ``TableRowEditorView`` | Edit; accepts ``FormData`` or a flat map |
| ``TableRowCreatorView`` | Create; usually empty ``FormData`` |

When a ``ModelAdmin`` is available, pass it into creator/editor for richer field configs; otherwise columns are plain strings.

See <doc:ClientHydration> for browser hydration and <doc:GettingStarted> for the model-driven list path (``IndexView``).
