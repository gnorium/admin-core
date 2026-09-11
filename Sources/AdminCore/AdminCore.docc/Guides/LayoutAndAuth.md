# Layout and Auth

Shell chrome and sign-in / MFA pages you compose into your app’s routes.

## LayoutView

``LayoutView`` is the admin shell: optional sidebar, optional navbar, main content. Nest it inside your product layout (or use it alone):

```swift
LayoutView(
  username: currentUser.name,
  showNavbar: true,
  showSidebar: true
) {
  IndexView(admin: admin, rows: rows)
}
```

| Parameter | Behavior |
| --- | --- |
| `navbar` / `sidebar` | Custom nodes; when non-`nil`, replace defaults |
| `showNavbar` / `showSidebar` | When true and custom is `nil`, render ``NavbarView`` / ``SidebarView`` |
| `signOutUrl` | Defaults to `{baseRoute}/sign-out` |

Base path for links comes from ``Configuration/shared``.

## Sidebar and navbar

- ``SidebarView`` — default destinations (dashboard, users, database, …) or pass ``SidebarItem`` arrays.
- ``NavbarView`` — site name, welcome line, sign out.

## Auth pages

| View | Role |
| --- | --- |
| ``SignInView`` | Username / password form |
| ``RegisterView`` | Invite-token account creation |
| ``SetupMFAView`` | TOTP enrollment (secret + otpauth URL) |
| ``VerifyMFAView`` | 6-digit challenge after password |

These are HTML fragments — wire form `action`s and sessions in your server. MFA client helpers: `SetupMFAHydration`, `VerifyMFAHydration` (see <doc:ClientHydration>).

## Configuration

Set once at startup:

```swift
Configuration.shared = Configuration(baseRoute: "/admin-console")
```

All default admin links resolve under that prefix.
