// RFC_9557.TimeZone.swift
// swift-rfc-9557
//
// RFC 9557 Time Zone Annotation

extension RFC_9557 {
    /// Time zone annotation for RFC 9557 timestamps
    ///
    /// Represents the optional time zone suffix in IXDTF format.
    ///
    /// ## Types
    ///
    /// - **IANA Time Zone**: Named zone from IANA Time Zone Database
    /// - **Offset Time Zone**: Numeric UTC offset
    ///
    /// ## Critical Flag
    ///
    /// The critical flag (`!`) indicates whether the receiver must process
    /// or understand the time zone annotation:
    /// - `critical: true` - Receiver must process or reject
    /// - `critical: false` - Receiver may ignore if unsupported
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // IANA time zone (elective)
    /// let tz1 = RFC_9557.TimeZone.iana("Europe/Paris", critical: false)
    ///
    /// // IANA time zone (critical - must process)
    /// let tz2 = RFC_9557.TimeZone.iana("America/New_York", critical: true)
    ///
    /// // Offset time zone
    /// let tz3 = RFC_9557.TimeZone.offset("+08:45", critical: false)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Suffix``
    /// - ``ExtendedDateTime``
    public enum TimeZone: Sendable, Equatable, Hashable {
        /// IANA Time Zone Database identifier
        ///
        /// - Parameters:
        ///   - identifier: Time zone name (e.g., "America/Los_Angeles")
        ///   - critical: Whether receiver must process this annotation
        case iana(String, critical: Bool)

        /// Numeric UTC offset as string
        ///
        /// - Parameters:
        ///   - offset: Offset string (e.g., "+08:45", "-05:00")
        ///   - critical: Whether receiver must process this annotation
        case offset(String, critical: Bool)
    }
}

// MARK: - Properties

extension RFC_9557.TimeZone {
    /// Whether this time zone annotation is marked as critical
    public var isCritical: Bool {
        switch self {
        case .iana(_, let critical), .offset(_, let critical):
            return critical
        }
    }

    /// The time zone identifier or offset string
    public var identifier: String {
        switch self {
        case .iana(let id, _), .offset(let id, _):
            return id
        }
    }
}
