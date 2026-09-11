#if SERVER
  import Foundation

  /// Central registry of ``ModelAdmin`` definitions for the admin console.
  ///
  /// Register models at startup, then resolve them by URL path when routing:
  ///
  /// ```swift
  /// Registry.shared.register(ArticleAdmin())
  /// let admin = Registry.shared.admin(for: "articles")
  /// ```
  public final class Registry: @unchecked Sendable {
    /// Shared process-wide registry.
    public static let shared = Registry()

    private var admins: [String: AnyModelAdmin] = [:]
    private let lock = NSLock()

    private init() {}

    /// Registers a model admin under its ``ModelAdmin/urlPath``.
    public func register<T: ModelAdmin>(_ admin: T) {
      lock.lock()
      defer { lock.unlock() }
      admins[admin.urlPath] = AnyModelAdmin(admin)
    }

    /// All registered admins, sorted by plural model name.
    public func allAdmins() -> [AnyModelAdmin] {
      lock.lock()
      defer { lock.unlock() }
      return Array(admins.values).sorted { $0.modelNamePlural < $1.modelNamePlural }
    }

    /// Looks up an admin by URL path segment.
    public func admin(for urlPath: String) -> AnyModelAdmin? {
      lock.lock()
      defer { lock.unlock() }
      return admins[urlPath]
    }

    /// Returns whether an admin is registered for the given path.
    public func isRegistered(_ urlPath: String) -> Bool {
      lock.lock()
      defer { lock.unlock() }
      return admins[urlPath] != nil
    }

    /// Removes all registrations (intended for tests).
    public func clear() {
      lock.lock()
      defer { lock.unlock() }
      admins.removeAll()
    }
  }
#endif
