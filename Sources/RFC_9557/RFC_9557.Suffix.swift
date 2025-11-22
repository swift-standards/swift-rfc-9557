// RFC_9557.Suffix.swift
// swift-rfc-9557
//
// RFC 9557 Suffix Annotations

extension RFC_9557 {
    /// Suffix annotations for RFC 9557 extended timestamps
    ///
    /// Contains optional metadata appended to RFC 3339 timestamps.
    ///
    /// ## Components
    ///
    /// - **Time Zone**: IANA identifier or numeric offset
    /// - **Calendar**: Unicode calendar system identifier (u-ca)
    /// - **Custom Tags**: Additional key-value pairs
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Time zone only
    /// let suffix1 = RFC_9557.Suffix(
    ///     timeZone: .iana("Europe/Paris", critical: false)
    /// )
    ///
    /// // Time zone + calendar
    /// let suffix2 = RFC_9557.Suffix(
    ///     timeZone: .iana("Asia/Jerusalem", critical: false),
    ///     calendar: "hebrew"
    /// )
    ///
    /// // With custom tags
    /// let suffix3 = RFC_9557.Suffix(
    ///     timeZone: .iana("America/New_York", critical: true),
    ///     tags: [
    ///         SuffixTag(key: "_source", values: ["gps"], critical: false)
    ///     ]
    /// )
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``TimeZone``
    /// - ``SuffixTag``
    /// - ``ExtendedDateTime``
    public struct Suffix: Sendable, Equatable, Hashable {
        /// Optional time zone annotation
        public let timeZone: TimeZone?

        /// Optional calendar system preference (u-ca key)
        ///
        /// Unicode calendar identifier per TR35.
        /// Example values: "gregory", "hebrew", "islamic", "buddhist"
        public let calendar: String?

        /// Additional suffix tags
        public let tags: [SuffixTag]

        /// Create suffix with components
        ///
        /// - Parameters:
        ///   - timeZone: Optional time zone annotation
        ///   - calendar: Optional calendar system identifier
        ///   - tags: Additional suffix tags (default: empty)
        public init(
            timeZone: TimeZone? = nil,
            calendar: String? = nil,
            tags: [SuffixTag] = []
        ) {
            self.timeZone = timeZone
            self.calendar = calendar
            self.tags = tags
        }
    }

    /// Individual suffix tag (key-value pair)
    ///
    /// Represents a tagged annotation in the suffix.
    ///
    /// ## Format
    ///
    /// ```
    /// [critical-flag key=value1-value2-value3]
    /// ```
    ///
    /// ## Rules
    ///
    /// - Keys must be lowercase
    /// - Keys starting with `_` are experimental
    /// - Values are case-sensitive
    /// - Multiple values separated by hyphens
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Standard tag (elective)
    /// let tag1 = RFC_9557.SuffixTag(
    ///     key: "u-ca",
    ///     values: ["hebrew"],
    ///     critical: false
    /// )
    ///
    /// // Experimental tag (critical)
    /// let tag2 = RFC_9557.SuffixTag(
    ///     key: "_clksrc",
    ///     values: ["ntp", "atomic"],
    ///     critical: true
    /// )
    /// ```
    public struct SuffixTag: Sendable, Equatable, Hashable {
        /// Tag key (lowercase)
        public let key: String

        /// Tag values (case-sensitive)
        public let values: [String]

        /// Whether this tag is critical
        public let critical: Bool

        /// Create suffix tag
        ///
        /// - Parameters:
        ///   - key: Tag key (must be lowercase)
        ///   - values: Tag values (case-sensitive)
        ///   - critical: Whether receiver must process this tag
        public init(key: String, values: [String], critical: Bool) {
            self.key = key
            self.values = values
            self.critical = critical
        }

        /// Whether this is an experimental tag (key starts with underscore)
        public var isExperimental: Bool {
            key.hasPrefix("_")
        }
    }
}

// MARK: - Convenience Properties

extension RFC_9557.Suffix {
    /// Whether any component is marked as critical
    public var hasCriticalComponents: Bool {
        if timeZone?.isCritical == true {
            return true
        }
        return tags.contains { $0.critical }
    }

    /// All tags including calendar as a tag if present
    public var allTags: [RFC_9557.SuffixTag] {
        var result = tags
        if let calendar = calendar {
            result.insert(
                RFC_9557.SuffixTag(key: "u-ca", values: [calendar], critical: false),
                at: 0
            )
        }
        return result
    }
}
