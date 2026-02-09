#if !os(WASI)

import CSSBuilder
import DesignTokens
import HTMLBuilder
import WebComponents
import WebTypes

/// A generic editor view that dynamically build forms from FieldConfig
public struct EditorView: HTMLProtocol {
    let admin: AnyModelAdminProtocol
    let data: FormData
    let isNew: Bool
    
    public init(admin: AnyModelAdminProtocol, data: FormData, isNew: Bool = true) {
        self.admin = admin
        self.data = data
        self.isNew = isNew
    }
    
    public func render(indent: Int = 0) -> String {
        div {
            header {
                h1 { isNew ? "New \(admin.modelName)" : "Edit \(admin.modelName)" }
                    .style {
                        fontFamily(typographyFontSans)
                        fontSize(px(24))
                        fontWeight(600)
                        color(colorBase)
                        marginBottom(spacing8)
                    }

                p { "Fill in the details for the \(admin.modelName.lowercased())" }
                    .style {
                        fontSize(fontSizeSmall14)
                        color(colorSubtle)
                    }
            }
            .style {
                marginBottom(spacing32)
            }

            form {
                for field in admin.editFields {
                    div {
                        label { 
                            field.label 
                            if !field.required {
                                span { " (optional)" }
                                    .style {
                                        fontWeight(.normal)
                                        color(colorSubtle)
                                    }
                            }
                        }
                        .for(field.name)
                        .style { formLabelStyle() }

                        renderField(field)
                        
                        if let helpText = field.helpText {
                            p { helpText }
                                .style {
                                    fontSize(fontSizeSmall14)
                                    color(colorSubtle)
                                    fontStyle(.italic)
                                    marginTop(spacing4)
                                }
                        }
                    }
                    .style { formGroupStyle() }
                }

                // Actions
                div {
                    ButtonView(
                        label: isNew ? "Create" : "Update",
                        buttonColor: .blue,
                        weight: .solid,
                        size: .large,
                        type: .submit
                    )

                    a { ButtonView(label: "Cancel", weight: .subtle, size: .large) }
                        .href("/admin/\(admin.urlPath)")
                        .style {
                            textDecoration(.none)
                        }
                }
                .style {
                    display(.flex)
                    gap(spacing16)
                    paddingTop(spacing16)
                    borderTop(borderWidthBase, borderStyleBase, borderColorSubtle)
                }
            }
            .action(isNew ? "/admin/\(admin.urlPath)" : "/admin/\(admin.urlPath)/\(data.id ?? "")")
            .method(.post)
            .style {
                display(.flex)
                flexDirection(.column)
                gap(spacing24)
            }
        }
        .class("editor-view")
        .style {
            maxWidth(px(1280))
            margin(0, .auto)
            padding(spacing48, spacing24)
        }
        .render(indent: indent)
    }
    
    @HTMLBuilder
    private func renderField(_ field: FieldConfig) -> HTMLProtocol {
        let value = data.values[field.name] ?? field.defaultValue ?? ""
        
        switch field.fieldType {
        case .text, .email, .url, .password, .number, .date, .datetime:
            input()
                .type(inputType(for: field.fieldType))
                .id(field.name)
                .name(field.name)
                .value(value)
                .required(field.required)
                .placeholder(field.placeholder ?? field.label)
                .readonly(field.readOnly)
                .style { formInputStyle() }
                
        case .textarea:
            textarea { value }
                .id(field.name)
                .name(field.name)
                .required(field.required)
                .placeholder(field.placeholder ?? field.label)
                .rows(5)
                .readonly(field.readOnly)
                .style { formInputStyle() }
                
        case .checkbox:
            label {
                input()
                    .type(.checkbox)
                    .id(field.name)
                    .name(field.name)
                    .value("true")
                    .checked(value == "true")
                    .readonly(field.readOnly)
                    .style {
                        width(px(20))
                        height(px(20))
                        cursor(.pointer)
                    }
                " \(field.label)"
            }
            .for(field.name)
            .style {
                display(.flex)
                alignItems(.center)
                gap(spacing8)
            }
            
        case .select:
            select {
                if let options = field.options {
                    for opt in options {
                        option { opt.1 }
                            .value(opt.0)
                            .selected(value == opt.0)
                    }
                }
            }
            .id(field.name)
            .name(field.name)
            .required(field.required)
            .style { formInputStyle() }
            
        case .tags:
            input()
                .type(.text)
                .id(field.name)
                .name(field.name)
                .value(data.multiValues[field.name]?.joined(separator: ", ") ?? value)
                .placeholder(field.placeholder ?? "Comma separated tags")
                .readonly(field.readOnly)
                .style { formInputStyle() }
                
        case .markdown:
            textarea { value }
                .id(field.name)
                .name(field.name)
                .required(field.required)
                .placeholder(field.placeholder ?? "Markdown content")
                .readonly(field.readOnly)
                .style {
                    formInputStyle()
                    minHeight(px(400))
                    fontFamily(typographyFontMono)
                    lineHeight(1.6)
                    resize(.vertical)
                }
                
        case .slug:
            input()
                .type(.text)
                .id(field.name)
                .name(field.name)
                .value(value)
                .required(field.required)
                .placeholder(field.placeholder ?? "slug-format")
                .readonly(field.readOnly)
                .style { formInputStyle() }
                
        case .hidden:
            input()
                .type(.hidden)
                .id(field.name)
                .name(field.name)
                .value(value)

        case .multiSelect:
            // Simplified for now, just text or hidden until we have a better UI component
            p { "Multi-select not yet implemented" }
        }
    }
    
    private func inputType(for type: FieldType) -> HTMLInput.`Type` {
        switch type {
        case .email: return .email
        case .url: return .url
        case .password: return .password
        case .number: return .number
        case .date: return .date
        case .datetime: return .text
        default: return .text
        }
    }

    @CSSBuilder
    private func formGroupStyle() -> [any CSSProtocol] {
        display(.flex)
        flexDirection(.column)
        gap(spacing8)
    }

    @CSSBuilder
    private func formLabelStyle() -> [any CSSProtocol] {
        fontSize(fontSizeMedium16)
        fontWeight(500)
        color(colorBase)
    }

    @CSSBuilder
    private func formInputStyle() -> [any CSSProtocol] {
        width(perc(100))
        padding(spacing12, spacing16)
        fontFamily(typographyFontSans)
        fontSize(fontSizeMedium16)
        color(colorBase)
        backgroundColor(backgroundColorBase)
        border(borderWidthBase, borderStyleBase, borderColorBase)
        borderRadius(borderRadiusBase)
    }
}

#endif

#if os(WASI)

import WebAPIs
import EmbeddedSwiftUtilities

public class EditorHydration: @unchecked Sendable {
    public init() {}
    public func hydrate() {}
}

#endif
