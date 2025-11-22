// RFC_9557.swift
// swift-rfc-9557
//
// RFC 9557: Internet Extended Date/Time Format (IXDTF)

/// RFC 9557: Internet Extended Date/Time Format
///
/// Authoritative namespace for RFC 9557 definitions and operations.
///
/// ## Overview
///
/// RFC 9557 extends RFC 3339 timestamps with optional suffix information:
/// - **Time zone identifiers**: IANA Time Zone Database names
/// - **Calendar system**: Unicode calendar identifiers (u-ca)
/// - **Critical flags**: Mandatory-to-process annotations
/// - **Custom tags**: Extensible key-value pairs
///
/// ## Extended Format
///
/// ```
/// date-time-ext = date-time suffix
/// suffix        = [time-zone] *suffix-tag
/// ```
///
/// ## Examples
///
/// ```swift
/// // RFC 3339 base timestamp
/// "1996-12-19T16:39:57-08:00"
///
/// // With IANA time zone
/// "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
///
/// // With calendar system
/// "1996-12-19T16:39:57-08:00[America/Los_Angeles][u-ca=hebrew]"
///
/// // With critical time zone (must process or reject)
/// "1996-12-19T16:39:57-08:00[!America/Los_Angeles]"
/// ```
///
/// ## RFC 3339 Interpretation Update
///
/// RFC 9557 updates the interpretation of `Z` in RFC 3339:
/// - `Z`: UTC time known, local offset unknown (equivalent to `-00:00`)
/// - `+00:00`: UTC is the preferred reference point
///
/// This differs from the original RFC 3339 interpretation where both were equivalent.
///
/// ## See Also
///
/// - ``ExtendedDateTime``
/// - ``Suffix``
/// - ``Parser``
/// - ``Formatter``
public enum RFC_9557 {}
