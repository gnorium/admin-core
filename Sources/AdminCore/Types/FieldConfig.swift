#if SERVER
  import Foundation

  /// Input control kinds for admin create/edit forms.
  public enum FieldType: String, Sendable {
    /// Single-line text input.
    case text
    /// Multi-line textarea.
    case textarea
    /// Email field with validation.
    case email
    /// URL field.
    case url
    /// Password field (masked).
    case password
    /// Number input.
    case number
    /// Date picker.
    case date
    /// Date-time picker.
    case datetime
    /// Checkbox (boolean).
    case checkbox
    /// Select dropdown.
    case select
    /// Multi-select control.
    case multiSelect
    /// Hidden field (not shown to the user).
    case hidden
    /// Slug field, optionally derived from another field.
    case slug
    /// Tags / chips input.
    case tags
    /// Markdown / rich text editor.
    case markdown
  }

  /// Configuration for one form field in the admin interface.
  ///
  /// Prefer the factory methods (``text(_:label:required:placeholder:helpText:)``,
  /// ``slug(_:label:from:required:placeholder:helpText:)``,
  /// ``select(_:label:options:required:)``, and others) when defining ``ModelAdmin/editFields``.
  public struct FieldConfig: Sendable {
    /// Field name (matches the model property / form name).
    public let name: String
    /// Human-readable label shown next to the control.
    public let label: String
    /// Control type rendered in the form.
    public let fieldType: FieldType
    /// Whether the field is required.
    public let required: Bool
    /// Optional help text shown below the field.
    public let helpText: String?
    /// Optional placeholder text.
    public let placeholder: String?
    /// For select fields: options as `(value, label)` pairs.
    public let options: [(String, String)]?
    /// For slug fields: name of the source field used to generate the slug.
    public let slugSource: String?
    /// Default value as a string (booleans use `"true"` / `"false"`).
    public let defaultValue: String?
    /// When `true`, the field is shown but not editable.
    public let readOnly: Bool

    /// Creates a field configuration.
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

  // MARK: - Convenience factories

  extension FieldConfig {
    /// Single-line text field.
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

    /// Multi-line text field.
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

    /// Boolean checkbox.
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

    /// Dropdown select.
    ///
    /// - Parameters:
    ///   - name: Field name (form / model key).
    ///   - label: Display label.
    ///   - options: `(value, label)` pairs for each option.
    ///   - required: Whether the field is required.
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

    /// URL-safe slug, optionally derived from another field.
    ///
    /// - Parameters:
    ///   - name: Field name (form / model key).
    ///   - label: Display label (default `"Slug"`).
    ///   - source: Name of the source field used to generate the slug (e.g. `"title"`); call site: `from:`.
    ///   - required: Whether the field is required (default `true`).
    ///   - placeholder: Optional placeholder text.
    ///   - helpText: Optional help text below the field.
    public static func slug(
      _ name: String,
      label: String = "Slug",
      from source: String,
      required: Bool = true,
      placeholder: String? = nil,
      helpText: String? = nil
    ) -> FieldConfig {
      FieldConfig(
        name: name,
        label: label,
        fieldType: .slug,
        required: required,
        helpText: helpText,
        placeholder: placeholder,
        slugSource: source
      )
    }

    /// Tag / chip list field.
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

    /// Markdown body field.
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

    /// Hidden field with a fixed default value.
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
