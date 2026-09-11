# ``AdminCore``

Type-safe admin console building blocks for Swift web apps: model registration, forms, layout, and WASM hydration.

## Overview

AdminCore helps you ship an admin console without reinventing tables, auth screens, and database explorers.

- **Declarative models** — implement ``ModelAdmin`` and register with ``Registry``
- **Field configs** — ``FieldConfig`` / ``FieldType`` for create and edit forms
- **Pages** — list (``IndexView``), users, database browser, MFA, sign-in
- **Layout** — ``LayoutView`` with ``SidebarView`` and ``NavbarView``
- **Client** — WASM hydration types (`IndexHydration`, `UsersHydration`, and others) for selection and bulk actions

> **API reference scope:** DocC is built for the **server** (`SERVER`) target. Hydration types are compiled only for WebAssembly (`CLIENT` / wasi) and appear in <doc:ClientHydration> by name, not as linked symbols.

## Topics

### Guides

- <doc:GettingStarted>
- <doc:ModelsAndRegistry>
- <doc:FieldConfigs>
- <doc:LayoutAndAuth>
- <doc:DatabaseExplorer>
- <doc:ClientHydration>

### Configuration

- ``Configuration``
- ``Registry``

### Model admin

- ``ModelAdmin``
- ``AnyModelAdmin``
- ``FieldConfig``
- ``FieldType``
- ``ListRow``
- ``FormData``

### Layout

- ``LayoutView``
- ``NavbarView``
- ``SidebarView``
- ``SidebarItem``

### Model list pages

- ``IndexView``

### Auth and MFA

- ``SignInView``
- ``RegisterView``
- ``SetupMFAView``
- ``VerifyMFAView``

### Users

- ``UsersView``
- ``UsersViewConfig``
- ``UserRow``
- ``UserStats``

### Database explorer

- ``DatabaseView``
- ``DatabaseViewConfig``
- ``TableDisplayInfo``
- ``TableBrowserView``
- ``TableBrowserConfig``
- ``TableRowData``
- ``TableRowCreatorView``
- ``TableRowEditorView``
- ``TableRowDetailsView``
