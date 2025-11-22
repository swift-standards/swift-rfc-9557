// RFC_9557.Formatter.swift
// swift-rfc-9557
//
// RFC 9557 Formatter - Internet Extended Date/Time Format

extension RFC_9557 {
    /// RFC 9557 extended timestamp formatter
    ///
    /// Formats ``ExtendedDateTime`` values into RFC 9557 compliant strings.
    ///
    /// ## Output Format
    ///
    /// ```
    /// YYYY-MM-DDTHH:MM:SS[.fraction]±HH:MM[timezone][tags...]
    /// ```
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let time = try Time(year: 1996, month: 12, day: 19, hour: 16, minute: 39, second: 57)
    /// let base = RFC_3339.DateTime(time: time, offset: .offset(seconds: -28800))
    ///
    /// // Without suffix
    /// let dt1 = RFC_9557.ExtendedDateTime(base: base)
    /// RFC_9557.Formatter.format(dt1)
    /// // "1996-12-19T16:39:57-08:00"
    ///
    /// // With time zone
    /// let suffix = RFC_9557.Suffix(timeZone: .iana("America/Los_Angeles", critical: false))
    /// let dt2 = RFC_9557.ExtendedDateTime(base: base, suffix: suffix)
    /// RFC_9557.Formatter.format(dt2)
    /// // "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
    /// ```
    public enum Formatter {}
}

// MARK: - Format

extension RFC_9557.Formatter {
    /// Format extended date-time to RFC 9557 string
    ///
    /// - Parameter dateTime: Extended date-time to format
    /// - Returns: RFC 9557 formatted string
    public static func format(_ dateTime: RFC_9557.ExtendedDateTime) -> String {
        var result = RFC_3339.Formatter.format(dateTime.base)

        if let suffix = dateTime.suffix {
            result += formatSuffix(suffix)
        }

        return result
    }

    /// Format suffix annotations
    private static func formatSuffix(_ suffix: RFC_9557.Suffix) -> String {
        var result = ""

        // Time zone first
        if let timeZone = suffix.timeZone {
            result += formatTimeZone(timeZone)
        }

        // Calendar system
        if let calendar = suffix.calendar {
            result += "[u-ca=\(calendar)]"
        }

        // Additional tags
        for tag in suffix.tags {
            result += formatTag(tag)
        }

        return result
    }

    /// Format time zone annotation
    private static func formatTimeZone(_ timeZone: RFC_9557.TimeZone) -> String {
        let critical = timeZone.isCritical ? "!" : ""
        return "[\(critical)\(timeZone.identifier)]"
    }

    /// Format suffix tag
    private static func formatTag(_ tag: RFC_9557.SuffixTag) -> String {
        let critical = tag.critical ? "!" : ""
        let values = tag.values.joined(separator: "-")
        return "[\(critical)\(tag.key)=\(values)]"
    }
}
