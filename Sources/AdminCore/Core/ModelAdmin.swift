#if !os(WASI)

import Foundation

/// Protocol defining how a model is displayed and edited in the admin interface.
/// Implement this for each model you want to manage in the admin panel.
public protocol ModelAdmin: Sendable {
	/// Singular model name (e.g., "Article")
	var modelName: String { get }
	
	/// Plural model name (e.g., "Articles")
	var modelNamePlural: String { get }
	
	/// URL path segment for this model (e.g., "articles")
	var urlPath: String { get }
	
	/// Fields to display in the list view (column names)
	var listFields: [String] { get }
	
	/// Field configurations for the edit/create form
	var editFields: [FieldConfig] { get }
	
	/// Fields that are searchable in the list view
	var searchFields: [String] { get }
	
	/// Default sort field
	var defaultSortField: String { get }
	
	/// Default sort direction (true = ascending)
	var defaultSortAscending: Bool { get }
	
	/// Number of items per page
	var itemsPerPage: Int { get }
	
	/// Column headers for list view (maps field name to display label)
	var listHeaders: [String: String] { get }
}

// MARK: - Default Implementations

extension ModelAdmin {
	public var urlPath: String {
		modelNamePlural.lowercased().replacingOccurrences(of: " ", with: "-")
	}
	
	public var searchFields: [String] { [] }
	
	public var defaultSortField: String { "id" }
	
	public var defaultSortAscending: Bool { false }
	
	public var itemsPerPage: Int { 25 }
	
	public var listHeaders: [String: String] {
		Dictionary(uniqueKeysWithValues: listFields.map { ($0, $0.capitalized) })
	}
}

/// Type-erased container for ModelAdmin to allow heterogeneous storage
public struct AnyModelAdmin: Sendable {
	public let modelName: String
	public let modelNamePlural: String
	public let urlPath: String
	public let listFields: [String]
	public let editFields: [FieldConfig]
	public let searchFields: [String]
	public let defaultSortField: String
	public let defaultSortAscending: Bool
	public let itemsPerPage: Int
	public let listHeaders: [String: String]
	
	public init<T: ModelAdmin>(_ admin: T) {
		self.modelName = admin.modelName
		self.modelNamePlural = admin.modelNamePlural
		self.urlPath = admin.urlPath
		self.listFields = admin.listFields
		self.editFields = admin.editFields
		self.searchFields = admin.searchFields
		self.defaultSortField = admin.defaultSortField
		self.defaultSortAscending = admin.defaultSortAscending
		self.itemsPerPage = admin.itemsPerPage
		self.listHeaders = admin.listHeaders
	}
}

#endif
