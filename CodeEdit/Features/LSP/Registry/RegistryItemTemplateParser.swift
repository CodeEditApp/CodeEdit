//
//  RegistryItemTemplateParser.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/9/25.
//

import Foundation

/// This parser is used to parse expressions that may be included in a field of a registry item.
///
/// Example:
/// "protolint_{{ version | strip_prefix \"v\" }}_darwin_arm64.tar.gz" will be parsed into:
/// protolint_0.53.0_darwin_arm64.tar.gz
enum RegistryItemTemplateParser {

    enum TemplateError: Error {
        case invalidFilter(String)
        case missingVariable(String)
        case invalidPath(String)
        case missingKey(String)
    }

    private enum Filter {
        case stripPrefix(String)

        static func parse(_ filterString: String) throws -> Filter {
            let components = filterString.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
            if components.count >= 2 && components[0] == "strip_prefix" {
                // Extract the quoted string value
                let prefixRaw = components[1]
                if prefixRaw.hasPrefix("\"") && prefixRaw.hasSuffix("\"") {
                    let prefix = String(prefixRaw.dropFirst().dropLast())
                    return .stripPrefix(prefix)
                }
            }
            throw TemplateError.invalidFilter(filterString)
        }

        func apply(to value: String) -> String {
            switch self {
            case .stripPrefix(let prefix):
                if value.hasPrefix(prefix) {
                    return String(value.dropFirst(prefix.count))
                }
                return value
            }
        }
    }

    static func process(template: String, with context: [String: Any]) throws -> String {
        var result = template

        // Find all {{ ... }} patterns
        let pattern = "\\{\\{([^\\}]+)\\}\\}"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(
            in: template,
            options: [],
            range: NSRange(location: 0, length: template.utf16.count)
        )

        // Process matches in reverse order to not invalidate ranges
        for match in matches.reversed() {
            guard Range(match.range, in: template) != nil else { continue }

            // Extract the content between {{ and }}
            let expressionRange = Range(match.range(at: 1), in: template)!
            let expression = String(template[expressionRange])

            // Split by pipe to separate variable path from filters
            let components = expression.components(separatedBy: "|").filter { !$0.isEmpty }
            let pathExpression = components[0].trimmingCharacters(in: .whitespaces)
            let value = try getValueFromPath(pathExpression, in: context)

            // Apply filters
            var processedValue = value
            if components.count > 1 {
                for item in 1..<components.count {
                    let filterString = components[item].trimmingCharacters(in: .whitespaces)
                    let filter = try Filter.parse(filterString)
                    processedValue = filter.apply(to: processedValue)
                }
            }

            // Replace in result
            if let matchRange = Range(match.range, in: result) {
                result = result.replacingCharacters(in: matchRange, with: processedValue)
            }
        }

        return result
    }

    /// Get a value by traversing a dot-separated path in a nested dictionary
    private static func getValueFromPath(_ path: String, in context: [String: Any]) throws -> String {
        let pathComponents = path.components(separatedBy: ".")
        var currentValue: Any = context

        for component in pathComponents {
            if let dict = currentValue as? [String: Any] {
                if let value = dict[component] {
                    currentValue = value
                } else {
                    throw TemplateError.missingKey(component)
                }
            } else if let array = currentValue as? [Any], let index = Int(component) {
                if index >= 0 && index < array.count {
                    currentValue = array[index]
                } else {
                    throw TemplateError.invalidPath("Array index out of bounds: \(component)")
                }
            } else {
                throw TemplateError.invalidPath("Cannot access component: \(component)")
            }
        }

        // Convert the final value to a string
        if let stringValue = currentValue as? String {
            return stringValue
        } else if let intValue = currentValue as? Int {
            return String(intValue)
        } else if let doubleValue = currentValue as? Double {
            return String(doubleValue)
        } else if let boolValue = currentValue as? Bool {
            return String(boolValue)
        } else if currentValue is [Any] || currentValue is [String: Any] {
            throw TemplateError.invalidPath("Path resolves to a complex object, not a simple value")
        } else {
            return String(describing: currentValue)
        }
    }
}
