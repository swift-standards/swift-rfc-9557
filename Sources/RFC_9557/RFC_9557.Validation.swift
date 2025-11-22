// RFC_9557.Validation.swift
// swift-rfc-9557
//
// RFC 9557 Validation Rules

extension RFC_9557 {
    /// Validation rules for RFC 9557 components
    ///
    /// Implements format validation per RFC 9557 ABNF grammar.
    ///
    /// ## Validation Categories
    ///
    /// - **Suffix Keys**: Lowercase, start with letter/underscore, alphanumeric + hyphens
    /// - **Suffix Values**: Alphanumeric characters only
    /// - **Time Zone Names**: IANA format (alphanumeric, dots, underscores, hyphens, plus, slash)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Validate suffix key
    /// try RFC_9557.Validation.validateSuffixKey("u-ca")  // OK
    /// try RFC_9557.Validation.validateSuffixKey("U-CA")  // Error: not lowercase
    ///
    /// // Validate time zone name
    /// try RFC_9557.Validation.validateTimeZoneName("America/Los_Angeles")  // OK
    /// try RFC_9557.Validation.validateTimeZoneName(".")  // Error: invalid name
    /// ```
    public enum Validation {}
}

// MARK: - Suffix Key Validation

extension RFC_9557.Validation {
    /// Validate suffix key format
    ///
    /// Per RFC 9557 ABNF:
    /// ```
    /// suffix-key = key-initial *key-char
    /// key-initial = lcalpha / "_"
    /// key-char = key-initial / DIGIT / "-"
    /// ```
    ///
    /// - Parameter key: Suffix key to validate
    /// - Throws: `ParserError.invalidSuffixKey` if format is invalid
    public static func validateSuffixKey(_ key: String) throws {
        guard !key.isEmpty else {
            throw RFC_9557.ParserError.invalidSuffixKey(key)
        }

        // Check first character: must be lowercase letter or underscore
        guard let first = key.first,
              first == "_" || (first >= "a" && first <= "z") else {
            throw RFC_9557.ParserError.invalidSuffixKey(key)
        }

        // Check remaining characters: lowercase letters, digits, hyphens, underscores
        for char in key {
            let isValid = (char >= "a" && char <= "z") ||
                         (char >= "0" && char <= "9") ||
                         char == "-" ||
                         char == "_"
            guard isValid else {
                throw RFC_9557.ParserError.invalidSuffixKey(key)
            }
        }
    }

    /// Check if key is experimental (starts with underscore)
    ///
    /// Experimental keys are reserved for use in controlled environments
    /// and must not be used for interchange.
    ///
    /// - Parameter key: Suffix key to check
    /// - Returns: True if key starts with underscore
    public static func isExperimentalKey(_ key: String) -> Bool {
        key.hasPrefix("_")
    }
}

// MARK: - Suffix Value Validation

extension RFC_9557.Validation {
    /// Validate suffix value format
    ///
    /// Per RFC 9557 ABNF:
    /// ```
    /// suffix-value = 1*alphanum
    /// alphanum = ALPHA / DIGIT
    /// ```
    ///
    /// - Parameter value: Suffix value to validate
    /// - Throws: `ParserError.invalidSuffixValue` if format is invalid
    public static func validateSuffixValue(_ value: String) throws {
        guard !value.isEmpty else {
            throw RFC_9557.ParserError.invalidSuffixValue(value)
        }

        // All characters must be alphanumeric
        for char in value {
            let isValid = (char >= "a" && char <= "z") ||
                         (char >= "A" && char <= "Z") ||
                         (char >= "0" && char <= "9")
            guard isValid else {
                throw RFC_9557.ParserError.invalidSuffixValue(value)
            }
        }
    }
}

// MARK: - Time Zone Name Validation

extension RFC_9557.Validation {
    /// Validate time zone name format
    ///
    /// Per RFC 9557:
    /// - Alphanumeric characters, dots, underscores, hyphens, plus signs, forward slashes
    /// - Parts separated by "/" cannot be "." or ".."
    ///
    /// - Parameter name: Time zone name to validate
    /// - Throws: `ParserError.invalidTimeZoneName` if format is invalid
    public static func validateTimeZoneName(_ name: String) throws {
        guard !name.isEmpty else {
            throw RFC_9557.ParserError.invalidTimeZoneName(name)
        }

        let parts = name.split(separator: "/")

        // Check each part
        for part in parts {
            // Parts cannot be "." or ".."
            if part == "." || part == ".." {
                throw RFC_9557.ParserError.invalidTimeZoneName(name)
            }

            // Check characters: alphanumeric, dots, underscores, hyphens, plus
            for char in part {
                let isValid = (char >= "a" && char <= "z") ||
                             (char >= "A" && char <= "Z") ||
                             (char >= "0" && char <= "9") ||
                             char == "." ||
                             char == "_" ||
                             char == "-" ||
                             char == "+"
                guard isValid else {
                    throw RFC_9557.ParserError.invalidTimeZoneName(name)
                }
            }
        }
    }
}

// MARK: - Known Suffix Keys

extension RFC_9557.Validation {
    /// Registered suffix keys per IANA registry
    ///
    /// Currently only "u-ca" is registered as permanent.
    public static let registeredKeys: Set<String> = ["u-ca"]

    /// Check if a suffix key is registered
    ///
    /// - Parameter key: Suffix key to check
    /// - Returns: True if key is in IANA registry
    public static func isRegisteredKey(_ key: String) -> Bool {
        registeredKeys.contains(key)
    }
}
