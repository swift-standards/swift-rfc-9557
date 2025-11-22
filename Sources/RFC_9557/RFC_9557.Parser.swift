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
    private static func parseSuffix(_ string: String) throws -> RFC_9557.Suffix? {
        guard !string.isEmpty else {
            return nil
        }

        var timeZone: RFC_9557.TimeZone? = nil
        var calendar: String? = nil
        var tags: [RFC_9557.SuffixTag] = []

        // Split into bracket groups
        var remaining = string
        while !remaining.isEmpty {
            guard let start = remaining.firstIndex(of: "["),
                  let end = remaining.firstIndex(of: "]") else {
                break
            }

            let content = String(remaining[remaining.index(after: start)..<end])
            remaining = String(remaining[remaining.index(after: end)...])

            // Check for critical flag
            let critical = content.hasPrefix("!")
            let actualContent = critical ? String(content.dropFirst()) : content

            // Check if it's a tag (contains '=')
            if let eqIndex = actualContent.firstIndex(of: "=") {
                let key = String(actualContent[..<eqIndex])
                let valuesPart = String(actualContent[actualContent.index(after: eqIndex)...])
                let values = valuesPart.split(separator: "-").map(String.init)

                if key == "u-ca" {
                    calendar = values.first
                } else {
                    tags.append(RFC_9557.SuffixTag(key: key, values: values, critical: critical))
                }
            } else {
                // It's a time zone
                if actualContent.hasPrefix("+") || actualContent.hasPrefix("-") {
                    timeZone = .offset(actualContent, critical: critical)
                } else {
                    timeZone = .iana(actualContent, critical: critical)
                }
            }
        }

        if timeZone == nil && calendar == nil && tags.isEmpty {
            return nil
        }

        return RFC_9557.Suffix(timeZone: timeZone, calendar: calendar, tags: tags)
    }
}
