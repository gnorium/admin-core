#if SERVER
  import Foundation

  /// One row in a model list table (``IndexView``).
  public struct ListRow: Sendable, Identifiable {
    /// Stable identifier for the model instance (used as the table row id).
    public let id: String

    /// Column values keyed by field name (must match ``ModelAdmin/listFields``).
    public let values: [String: String]

    /// Creates a list row.
    public init(id: String, values: [String: String]) {
      self.id = id
      self.values = values
    }
  }

  /// Field values for a create/edit form.
  public struct FormData: Sendable {
    /// Instance id when editing; `nil` when creating.
    public let id: String?

    /// Single-value fields keyed by field name.
    public let values: [String: String]

    /// Multi-value fields (e.g. tags) keyed by field name.
    public let multiValues: [String: [String]]

    /// Creates form data for create or edit.
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
