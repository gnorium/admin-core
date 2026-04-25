#if SERVER
  import Foundation

  /// Field types supported in auto-generated admin forms
  public enum FieldType: String, Sendable {
    /// Single-line text input
    case text
    /// Multi-line textarea
    case textarea
    /// Email field with validation
    case email
    /// URL field
    case url
    /// Password field (masked)
    case password
    /// Number input
    case number
    /// Date picker
    case date
    /// DateTime picker
    case datetime
    /// Checkbox (boolean)
    case checkbox
    /// Select dropdown
    case select
    /// Multi-select
    case multiSelect
    /// Hidden field
    case hidden
    /// Slug field (auto-generated from another field)
    case slug
    /// Tags/chips input
    case tags
    /// Markdown/rich text editor
    case markdown
  }

  /// Configuration for a form field in the admin interface
  public struct FieldConfig: Sendable {
    /// Field name (matches model property)
    public let name: String
    /// Display label
    public let label: String
    /// Field type determines the input component
    public let fieldType: FieldType
    /// Whether the field is required
    public let required: Bool
    /// Help text shown below the field
    public let helpText: String?
    /// Placeholder text
    public let placeholder: String?
    /// For select fields: options as (value, label) pairs
    public let options: [(String, String)]?
    /// For slug fields: source field to generate from
    public let slugSource: String?
    /// Default value
    public let defaultValue: String?
    /// Whether field is read-only
    public let readOnly: Bool

    public init(
      name: String,
      label: String,
      fieldType: FieldType = .text,
      required: Bool = false,
      helpText: String? = nil,
      placeholder: String? = nil,
      options: [(String, String)]? = nil,
      slugSource: String? = nil,
      defaultValue: String? = nil,
      readOnly: Bool = false
    ) {
      self.name = name
      self.label = label
      self.fieldType = fieldType
      self.required = required
      self.helpText = helpText
      self.placeholder = placeholder
      self.options = options
      self.slugSource = slugSource
      self.defaultValue = defaultValue
      self.readOnly = readOnly
    }
  }

  // MARK: - Convenience Initializers

  extension FieldConfig {
    /// Text field shorthand
    public static func text(
      _ name: String,
      label: String,
      required: Bool = false,
      placeholder: String? = nil,
      helpText: String? = nil
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .text,
        required: required,
        helpText: helpText,
        placeholder: placeholder
      )
    }

    /// Textarea shorthand
    public static func textarea(
      _ name: String,
      label: String,
      required: Bool = false,
      placeholder: String? = nil,
      helpText: String? = nil
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .textarea,
        required: required,
        helpText: helpText,
        placeholder: placeholder
      )
    }

    /// Checkbox shorthand
    public static func checkbox(
      _ name: String,
      label: String,
      defaultValue: Bool = false
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .checkbox,
        required: false,
        defaultValue: defaultValue ? "true" : "false"
      )
    }

    /// Select dropdown shorthand
    public static func select(
      _ name: String,
      label: String,
      options: [(String, String)],
      required: Bool = false
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .select,
        required: required,
        options: options
      )
    }

    /// Slug field shorthand
    public static func slug(
      _ name: String,
      label: String = "Slug",
      from source: String
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .slug,
        required: true,
        slugSource: source
      )
    }

    /// Tags field shorthand
    public static func tags(
      _ name: String,
      label: String,
      helpText: String? = nil
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .tags,
        required: false,
        helpText: helpText
      )
    }

    /// Markdown editor shorthand
    public static func markdown(
      _ name: String,
      label: String,
      required: Bool = false
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .markdown,
        required: required
      )
    }

    /// Hidden field shorthand
    public static func hidden(_ name: String, value: String) -> FieldConfig {
      FieldConfig(
        name: name,
        label: "",
        fieldType: .hidden,
        defaultValue: value
      )
    }
  }
#endif
