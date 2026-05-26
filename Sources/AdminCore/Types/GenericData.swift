#if SERVER
  import Foundation

  /// Represents a single row in a generic model list view
  public struct ListRow: Sendable, Identifiable {
    /// Unique identifier for the model instance
    public let id: String

    /// Values for each column, indexed by field name
    public let values: [String: String]

    public init(id: String, values: [String: String]) {
      self.id = id
      self.values = values
    }
  }

  /// Represents the data for a generic model edit/create form
  public struct FormData: Sendable {
    /// Unique identifier for the model instance (nil for new items)
    public let id: String?

    /// Values for each field, indexed by field name
    public let values: [String: String]

    /// Multi-valued fields (e.g., tags), indexed by field name
    public let multiValues: [String: [String]]

    public init(
      id: String? = nil,
      values: [String: String] = [:],
      multiValues: [String: [String]] = [:]
    ) {
      self.id = id
      self.values = values
      self.multiValues = multiValues
    }
  }
#endif
