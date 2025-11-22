// String+RFC_9557.swift
// swift-rfc-9557
//
// String extensions for RFC 9557 parsing

extension String {
    /// Parse string as RFC 9557 extended date-time
    ///
    /// Convenience method for parsing RFC 9557 timestamps.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let timestamp = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
    /// let dt = try timestamp.rfc9557ExtendedDateTime()
    /// ```
    ///
    /// - Returns: Parsed extended date-time
    /// - Throws: Error if format is invalid
    public func rfc9557ExtendedDateTime() throws -> RFC_9557.ExtendedDateTime {
        try RFC_9557.Parser.parse(self)
    }

    /// Parse string as RFC 9557 extended date-time, allowing experimental tags
    ///
    /// Use in controlled environments where experimental tags (keys starting
    /// with `_`) are permitted.
    ///
    /// - Returns: Parsed extended date-time
    /// - Throws: Error if format is invalid
    public func rfc9557ExtendedDateTimeAllowingExperimental() throws -> RFC_9557.ExtendedDateTime {
        try RFC_9557.Parser.parseAllowingExperimental(self)
    }
}

extension Substring {
    /// Parse substring as RFC 9557 extended date-time
    ///
    /// Enables zero-copy parsing from string slices.
    ///
    /// - Returns: Parsed extended date-time
    /// - Throws: Error if format is invalid
    public func rfc9557ExtendedDateTime() throws -> RFC_9557.ExtendedDateTime {
        try RFC_9557.Parser.parse(self)
    }

    /// Parse substring as RFC 9557 extended date-time, allowing experimental tags
    ///
    /// - Returns: Parsed extended date-time
    /// - Throws: Error if format is invalid
    public func rfc9557ExtendedDateTimeAllowingExperimental() throws -> RFC_9557.ExtendedDateTime {
        try RFC_9557.Parser.parseAllowingExperimental(self)
    }
}
