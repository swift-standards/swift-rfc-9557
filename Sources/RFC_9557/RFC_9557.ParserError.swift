// RFC_9557.ParserError.swift
// swift-rfc-9557
//
// RFC 9557 Parser Errors

extension RFC_9557 {
    /// Errors that can occur during RFC 9557 parsing
    ///
    /// Represents validation failures and format errors specific to
    /// RFC 9557 extended date-time format.
    ///
    /// ## Error Categories
    ///
    /// - **Format Errors**: Invalid bracket structure, missing components
    /// - **Validation Errors**: Invalid keys, values, or time zone names
    /// - **Critical Tag Errors**: Critical tags that cannot be processed
    /// - **Experimental Tag Errors**: Experimental tags in non-experimental contexts
    ///
    /// ## Usage
    ///
    /// ```swift
    /// do {
    ///     let dt = try RFC_9557.Parser.parse(input)
    /// } catch let error as RFC_9557.ParserError {
    ///     switch error {
    ///     case .invalidSuffixKey(let key):
    ///         print("Invalid key: \(key)")
    ///     case .criticalTagNotSupported(let key):
    ///         print("Critical tag not supported: \(key)")
    ///     default:
    ///         print("Parse error: \(error)")
    ///     }
    /// }
    /// ```
    public enum ParserError: Error, Sendable, Equatable {
        // MARK: - Format Errors

        /// Unmatched or malformed brackets
        case malformedBrackets(String)

        /// Empty tag content
        case emptyTag

        /// Multiple time zones specified (only one allowed)
        case multipleTimeZones

        // MARK: - Validation Errors

        /// Suffix key does not meet format requirements
        ///
        /// Keys must:
        /// - Be lowercase only
        /// - Start with letter (a-z) or underscore
        /// - Contain only letters, digits, hyphens, underscores
        case invalidSuffixKey(String)

        /// Suffix value contains invalid characters
        ///
        /// Values must contain only alphanumeric characters
        case invalidSuffixValue(String)

        /// Time zone name does not meet IANA format requirements
        case invalidTimeZoneName(String)

        // MARK: - Critical Tag Errors

        /// Critical tag with unknown key must be rejected
        case criticalTagNotSupported(key: String)

        /// Critical experimental tag in non-experimental context
        case criticalExperimentalTag(key: String)

        // MARK: - Experimental Tag Errors

        /// Experimental tag (key starts with _) in interchange context
        ///
        /// Keys starting with underscore are reserved for experimental
        /// use in controlled environments only.
        case experimentalTagInInterchange(key: String)
    }
}

// MARK: - Error Descriptions

extension RFC_9557.ParserError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .malformedBrackets(let detail):
            return "Malformed brackets in suffix: \(detail)"
        case .emptyTag:
            return "Empty tag content in suffix"
        case .multipleTimeZones:
            return "Multiple time zones specified (only one allowed)"
        case .invalidSuffixKey(let key):
            return "Invalid suffix key '\(key)': must be lowercase, start with letter/underscore, contain only letters/digits/hyphens/underscores"
        case .invalidSuffixValue(let value):
            return "Invalid suffix value '\(value)': must contain only alphanumeric characters"
        case .invalidTimeZoneName(let name):
            return "Invalid time zone name '\(name)': must follow IANA format"
        case .criticalTagNotSupported(let key):
            return "Critical tag with unknown key '\(key)' cannot be processed"
        case .criticalExperimentalTag(let key):
            return "Critical experimental tag '\(key)' in non-experimental context"
        case .experimentalTagInInterchange(let key):
            return "Experimental tag '\(key)' not allowed in interchange (keys starting with _ are for controlled environments only)"
        }
    }
}
