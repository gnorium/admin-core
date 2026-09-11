#if SERVER
  import Foundation

  /// Runtime configuration for AdminCore (base URL path for all admin routes).
  ///
  /// Set ``shared`` early in application startup before rendering any admin views:
  ///
  /// ```swift
  /// Configuration.shared = Configuration(baseRoute: "/admin")
  /// ```
  public struct Configuration: Sendable {
    /// URL path prefix for the admin console (no trailing slash). Default: `"/admin-console"`.
    public var baseRoute: String

    /// Creates a configuration.
    /// - Parameter baseRoute: Root path for admin routes (e.g. `"/admin-console"`).
    public init(baseRoute: String = "/admin-console") {
      self.baseRoute = baseRoute
    }

    /// Process-wide configuration used by AdminCore views and links.
    public nonisolated(unsafe) static var shared = Configuration()
  }
#endif
