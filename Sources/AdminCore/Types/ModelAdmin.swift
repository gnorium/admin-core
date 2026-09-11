#if SERVER
  import Foundation

  /// Describes how one model appears and is edited in the admin console.
  ///
  /// Implement this for each model you register with ``Registry``:
  ///
  /// ```swift
  /// struct ArticleAdmin: ModelAdmin {
  ///   let modelName = "Article"
  ///   let modelNamePlural = "Articles"
  ///   let listFields = ["title", "slug", "status"]
  ///   var editFields: [FieldConfig] {
  ///     [
  ///       .text("title", label: "Title", required: true),
  ///       .slug("slug", label: "Slug", from: "title"),
  ///       .markdown("content", label: "Body"),
  ///     ]
  ///   }
  /// }
  /// Registry.shared.register(ArticleAdmin())
  /// ```
  public protocol ModelAdmin: Sendable {
    /// Singular model name (e.g. `"Article"`).
    var modelName: String { get }

    /// Plural model name (e.g. `"Articles"`).
    var modelNamePlural: String { get }

    /// URL path segment under the admin base route (e.g. `"articles"`).
    var urlPath: String { get }

    /// Field names shown as columns in the list view.
    var listFields: [String] { get }

    /// Field configurations for create/edit forms.
    var editFields: [FieldConfig] { get }

    /// Field names included in list search (default: none).
    var searchFields: [String] { get }

    /// Default sort field name (default: `"id"`).
    var defaultSortField: String { get }

    /// Default sort direction; `true` means ascending (default: `false`).
    var defaultSortAscending: Bool { get }

    /// Page size for list views (default: `25`).
    var itemsPerPage: Int { get }

    /// Column header labels keyed by field name (default: capitalized field names).
    var listHeaders: [String: String] { get }
  }

  // MARK: - Defaults

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

  /// Type-erased ``ModelAdmin`` for heterogeneous storage in ``Registry``.
  public struct AnyModelAdmin: Sendable {
    /// Singular model name.
    public let modelName: String
    /// Plural model name.
    public let modelNamePlural: String
    /// URL path segment.
    public let urlPath: String
    /// List column field names.
    public let listFields: [String]
    /// Edit form field configs.
    public let editFields: [FieldConfig]
    /// Searchable field names.
    public let searchFields: [String]
    /// Default sort field.
    public let defaultSortField: String
    /// Default sort ascending.
    public let defaultSortAscending: Bool
    /// List page size.
    public let itemsPerPage: Int
    /// List column headers.
    public let listHeaders: [String: String]

    /// Wraps any ``ModelAdmin`` implementation.
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
