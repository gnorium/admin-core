#if !os(WASI)

import Foundation

/// Central registry for admin models.
/// Register your ModelAdmin implementations to make them available in the admin interface.
public final class Registry: @unchecked Sendable {
	public static let shared = Registry()
	
	private var admins: [String: AnyModelAdmin] = [:]
	private let lock = NSLock()
	
	private init() {}
	
	/// Register a model admin
	public func register<T: ModelAdmin>(_ admin: T) {
		lock.lock()
		defer { lock.unlock() }
		admins[admin.urlPath] = AnyModelAdmin(admin)
	}
	
	/// Get all registered model admins
	public func allAdmins() -> [AnyModelAdmin] {
		lock.lock()
		defer { lock.unlock() }
		return Array(admins.values).sorted { $0.modelNamePlural < $1.modelNamePlural }
	}
	
	/// Get model admin by URL path
	public func admin(for urlPath: String) -> AnyModelAdmin? {
		lock.lock()
		defer { lock.unlock() }
		return admins[urlPath]
	}
	
	/// Check if a model is registered
	public func isRegistered(_ urlPath: String) -> Bool {
		lock.lock()
		defer { lock.unlock() }
		return admins[urlPath] != nil
	}
	
	/// Clear all registrations (useful for testing)
	public func clear() {
		lock.lock()
		defer { lock.unlock() }
		admins.removeAll()
	}
}

#endif
