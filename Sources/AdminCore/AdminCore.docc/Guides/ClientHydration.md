# Client Hydration

Server views emit HTML; WASM hydrations attach behavior (selection, bulk actions, QR, MFA input).

## Pattern

1. Server renders a view (e.g. ``IndexView``) with stable classes / data attributes.
2. Client startup constructs the matching hydration type (e.g. `IndexHydration`).
3. Hydration binds DOM events and updates controls when selection changes.

Hydration types are compiled only when `CLIENT` is defined for the **wasi** / Embedded Swift triple. They are not part of the macOS server binary.

## Hydration types

| Hydration | Pairs with |
| --- | --- |
| `IndexHydration` | ``IndexView`` |
| `UsersHydration` | ``UsersView`` |
| `TableBrowserHydration` | ``TableBrowserView`` |
| `TableRowDetailHydration` | ``TableRowDetailsView`` |
| `SetupMFAHydration` | ``SetupMFAView`` |
| `VerifyMFAHydration` | ``VerifyMFAView`` |

Typical client entry (sketch):

```swift
// After the page loads in the WASM client
IndexHydration.hydrateIfPresent()
// or construct the type and bind selectors matching the server markup
```

Exact entry points depend on your app’s hydration bootstrap (AdminCore types are the bindings; the host app calls them).

## Mental model

Server views are **descriptions** of markup. Hydrations are **long-lived** controllers for that markup. Don’t put click handlers in server-only code paths — put them on the client and keep form posts / navigation as normal HTML where possible.

## Why hydrations are not linked symbols in this API reference

DocC for this package is generated from the **server** (`SERVER`) build. Browser globals (`document`, `window`) and WebAPI client bindings only exist under `CLIENT` + WASM, so those types cannot be compiled into the host DocC graph without breaking `make run-server`. Use this guide for hydration names; use server view pages (``IndexView``, etc.) for linked API docs.
