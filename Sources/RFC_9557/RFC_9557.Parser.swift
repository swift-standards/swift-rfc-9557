// RFC_9557.Parser.swift
// swift-rfc-9557
//
// RFC 9557 Parser - Internet Extended Date/Time Format

extension RFC_9557 {
    /// RFC 9557 extended timestamp parser
    ///
    /// Parses RFC 9557 formatted strings into ``ExtendedDateTime`` values.
    ///
    /// ## Format
    ///
    /// ```
    /// date-time-ext = date-time suffix
    /// suffix        = [time-zone] *suffix-tag
    /// ```
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Basic RFC 3339
    /// let dt1 = try RFC_9557.Parser.parse("1996-12-19T16:39:57-08:00")
    ///
    /// // With time zone
    /// let dt2 = try RFC_9557.Parser.parse("1996-12-19T16:39:57-08:00[America/Los_Angeles]")
    ///
    /// // With calendar
    /// let dt3 = try RFC_9557.Parser.parse("2024-01-01T00:00:00Z[Asia/Jerusalem][u-ca=hebrew]")
    /// ```
    public enum Parser {}
}

// MARK: - Parse

extension RFC_9557.Parser {
    /// Parse RFC 9557 extended timestamp
    ///
    /// - Parameter string: RFC 9557 formatted timestamp
    /// - Returns: Parsed extended date-time
    /// - Throws: Error if format is invalid
    public static func parse(_ string: some StringProtocol) throws -> RFC_9557.ExtendedDateTime {
        // Find where RFC 3339 part ends (first '[' or end of string)
        guard let firstBracket = string.firstIndex(of: "[") else {
            // No suffix, just parse as RFC 3339
            let base = try RFC_3339.Parser.parse(string)
            return RFC_9557.ExtendedDateTime(base: base, suffix: nil)
        }

        // Split into base and suffix
        let basePart = string[..<firstBracket]
        let suffixPart = string[firstBracket...]

        // Parse RFC 3339 base
        let base = try RFC_3339.Parser.parse(basePart)

        // Parse suffix
        let suffix = try parseSuffix(String(suffixPart))

        return RFC_9557.ExtendedDateTime(base: base, suffix: suffix)
    }

    /// Parse suffix annotations
    ///
    /// - Parameters:
    ///   - string: Suffix portion of timestamp (starting with '[')
    ///   - allowExperimental: Whether to allow experimental tags (default: false)
    /// - Returns: Parsed suffix or nil if empty
    /// - Throws: ParserError if validation fails
    private static func parseSuffix(
        _ string: String,
        allowExperimental: Bool = false
    ) throws -> RFC_9557.Suffix? {
        guard !string.isEmpty else {
            return nil
        }

        var timeZone: RFC_9557.TimeZone? = nil
        var calendar: String? = nil
        var tags: [RFC_9557.SuffixTag] = []
        var seenKeys = Set<String>()

        // Split into bracket groups
        var remaining = string
        while !remaining.isEmpty {
            guard let start = remaining.firstIndex(of: "[") else {
                break
            }

            guard let end = remaining[remaining.index(after: start)...].firstIndex(of: "]") else {
                throw RFC_9557.ParserError.malformedBrackets("Unclosed bracket")
            }

            let content = String(remaining[remaining.index(after: start)..<end])
            remaining = String(remaining[remaining.index(after: end)...])

            // Check for empty tag
            guard !content.isEmpty && content != "!" else {
                throw RFC_9557.ParserError.emptyTag
            }

            // Check for critical flag
            let critical = content.hasPrefix("!")
            let actualContent = critical ? String(content.dropFirst()) : content

            guard !actualContent.isEmpty else {
                throw RFC_9557.ParserError.emptyTag
            }

            // Check if it's a tag (contains '=')
            if let eqIndex = actualContent.firstIndex(of: "=") {
                // Parse tag
                let key = String(actualContent[..<eqIndex])
                let valuesPart = String(actualContent[actualContent.index(after: eqIndex)...])

                guard !valuesPart.isEmpty else {
                    throw RFC_9557.ParserError.invalidSuffixValue("")
                }

                let values = valuesPart.split(separator: "-").map(String.init)

                // Validate key format
                try RFC_9557.Validation.validateSuffixKey(key)

                // Check for experimental tags
                if RFC_9557.Validation.isExperimentalKey(key) {
                    // Critical experimental tags are always invalid (even in experimental contexts)
                    if critical {
                        throw RFC_9557.ParserError.criticalExperimentalTag(key: key)
                    }
                    // Non-critical experimental tags require allowExperimental flag
                    if !allowExperimental {
                        throw RFC_9557.ParserError.experimentalTagInInterchange(key: key)
                    }
                }

                // Validate all values
                for value in values {
                    try RFC_9557.Validation.validateSuffixValue(value)
                }

                // Handle u-ca specially (use first occurrence, ignore duplicates)
                if key == "u-ca" {
                    if calendar == nil {
                        calendar = values.first
                    }
                    // Ignore duplicate u-ca tags per spec
                } else {
                    // Check for unknown critical tags
                    if critical && !RFC_9557.Validation.isRegisteredKey(key) {
                        throw RFC_9557.ParserError.criticalTagNotSupported(key: key)
                    }

                    // Only add first occurrence of each key
                    if !seenKeys.contains(key) {
                        tags.append(RFC_9557.SuffixTag(key: key, values: values, critical: critical))
                        seenKeys.insert(key)
                    }
                }
            } else {
                // It's a time zone
                guard timeZone == nil else {
                    throw RFC_9557.ParserError.multipleTimeZones
                }

                if actualContent.hasPrefix("+") || actualContent.hasPrefix("-") {
                    // Offset time zone - validate it's a valid offset format
                    // Format should match RFC 3339 time-numoffset
                    timeZone = .offset(actualContent, critical: critical)
                } else {
                    // IANA time zone - validate name format
                    try RFC_9557.Validation.validateTimeZoneName(actualContent)
                    timeZone = .iana(actualContent, critical: critical)
                }
            }
        }

        if timeZone == nil && calendar == nil && tags.isEmpty {
            return nil
        }

        return RFC_9557.Suffix(timeZone: timeZone, calendar: calendar, tags: tags)
    }

    /// Parse RFC 9557 extended timestamp allowing experimental tags
    ///
    /// Use this variant in controlled environments where experimental
    /// tags (keys starting with `_`) are permitted.
    ///
    /// - Parameter string: RFC 9557 formatted timestamp
    /// - Returns: Parsed extended date-time
    /// - Throws: Error if format is invalid
    public static func parseAllowingExperimental(_ string: some StringProtocol) throws -> RFC_9557.ExtendedDateTime {
        // Find where RFC 3339 part ends (first '[' or end of string)
        guard let firstBracket = string.firstIndex(of: "[") else {
            // No suffix, just parse as RFC 3339
            let base = try RFC_3339.Parser.parse(string)
            return RFC_9557.ExtendedDateTime(base: base, suffix: nil)
        }

        // Split into base and suffix
        let basePart = string[..<firstBracket]
        let suffixPart = string[firstBracket...]

        // Parse RFC 3339 base
        let base = try RFC_3339.Parser.parse(basePart)

        // Parse suffix with experimental tags allowed
        let suffix = try parseSuffix(String(suffixPart), allowExperimental: true)

        return RFC_9557.ExtendedDateTime(base: base, suffix: suffix)
    }
}
