// RFC_9557.ExtendedDateTime.swift
// swift-rfc-9557
//
// RFC 9557 Extended Date/Time Format

extension RFC_9557 {
    /// RFC 9557 extended date-time value
    ///
    /// Combines an RFC 3339 timestamp with optional suffix information.
    ///
    /// ## Structure
    ///
    /// An extended date-time consists of:
    /// - **base**: RFC 3339 timestamp (``RFC_3339/DateTime``)
    /// - **suffix**: Optional annotations (``Suffix``)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Parse extended timestamp
    /// let dt = try RFC_9557.Parser.parse("1996-12-19T16:39:57-08:00[America/Los_Angeles]")
    ///
    /// // Access base timestamp
    /// print(dt.base.time.year)  // 1996
    /// print(dt.base.offset)     // .offset(seconds: -28800)
    ///
    /// // Access suffix information
    /// if let tz = dt.suffix?.timeZone {
    ///     print(tz)  // .iana("America/Los_Angeles", critical: false)
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Suffix``
    /// - ``Parser``
    /// - ``Formatter``
    public struct ExtendedDateTime: Sendable, Equatable, Hashable {
        /// RFC 3339 base timestamp
        public let base: RFC_3339.DateTime

        /// Optional suffix annotations
        public let suffix: Suffix?

        /// Create extended date-time
        ///
        /// - Parameters:
        ///   - base: RFC 3339 timestamp
        ///   - suffix: Optional suffix annotations
        public init(base: RFC_3339.DateTime, suffix: Suffix? = nil) {
            self.base = base
            self.suffix = suffix
        }
    }
}
