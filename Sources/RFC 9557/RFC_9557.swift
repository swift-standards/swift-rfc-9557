// RFC_9557.swift
// swift-rfc-9557

/// RFC 9557: Date and Time on the Internet: Timestamps with Additional Information
///
/// Authoritative namespace for RFC 9557 Internet Extended Date/Time Format (IXDTF).
///
/// ## Overview
///
/// RFC 9557 extends RFC 3339 timestamps with optional suffix information:
/// - **Time zone identifiers**: IANA Time Zone Database names
/// - **Calendar system**: Unicode calendar identifiers (u-ca)
/// - **Critical flags**: Mandatory-to-process annotations
/// - **Custom tags**: Extensible key-value pairs
///
/// ## Key Types
///
/// - ``Timestamp``: Extended timestamp with RFC 3339 base + optional suffix
/// - ``Suffix``: Suffix annotations containing time zone, calendar, and tags
/// - ``Suffix.Tag``: Individual key-value tag
///
/// ## Example
///
/// ```swift
/// // Parse extended timestamp
/// let ts = try RFC_9557.Timestamp("1996-12-19T16:39:57-08:00[America/Los_Angeles]")
///
/// // Access components
/// print(ts.base.time.year)  // 1996
/// print(ts.suffix?.timeZone?.identifier)  // "America/Los_Angeles"
/// ```
///
/// ## See Also
///
/// - [RFC 9557](https://www.rfc-editor.org/rfc/rfc9557)
/// - [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339)
public enum RFC_9557 {}
