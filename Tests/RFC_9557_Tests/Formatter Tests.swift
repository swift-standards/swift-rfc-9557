// Formatter Tests.swift
// swift-rfc-9557
//
// Tests for RFC_9557.Formatter

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Formatter - Basic Formatting")
struct FormatterBasicTests {
    @Test("Format without suffix")
    func formatWithoutSuffix() throws {
        let time = try Time(year: 1996, month: 12, day: 19, hour: 16, minute: 39, second: 57)
        let base = RFC_3339.DateTime(time: time, offset: .offset(seconds: -28800))
        let dt = RFC_9557.ExtendedDateTime(base: base)

        let formatted = RFC_9557.Formatter.format(dt)
        #expect(formatted == "1996-12-19T16:39:57-08:00")
    }

    @Test("Format with IANA time zone")
    func formatWithIANATimeZone() throws {
        let time = try Time(year: 1996, month: 12, day: 19, hour: 16, minute: 39, second: 57)
        let base = RFC_3339.DateTime(time: time, offset: .offset(seconds: -28800))
        let suffix = RFC_9557.Suffix(timeZone: .iana("America/Los_Angeles", critical: false))
        let dt = RFC_9557.ExtendedDateTime(base: base, suffix: suffix)

        let formatted = RFC_9557.Formatter.format(dt)
        #expect(formatted == "1996-12-19T16:39:57-08:00[America/Los_Angeles]")
    }

    @Test("Format with critical time zone")
    func formatWithCriticalTimeZone() throws {
        let time = try Time(year: 1996, month: 12, day: 19, hour: 16, minute: 39, second: 57)
        let base = RFC_3339.DateTime(time: time, offset: .offset(seconds: -28800))
        let suffix = RFC_9557.Suffix(timeZone: .iana("America/Los_Angeles", critical: true))
        let dt = RFC_9557.ExtendedDateTime(base: base, suffix: suffix)

        let formatted = RFC_9557.Formatter.format(dt)
        #expect(formatted == "1996-12-19T16:39:57-08:00[!America/Los_Angeles]")
    }

    @Test("Format with calendar system")
    func formatWithCalendar() throws {
        let time = try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        let base = RFC_3339.DateTime(time: time, offset: .utc)
        let suffix = RFC_9557.Suffix(
            timeZone: .iana("Asia/Jerusalem", critical: false),
            calendar: "hebrew"
        )
        let dt = RFC_9557.ExtendedDateTime(base: base, suffix: suffix)

        let formatted = RFC_9557.Formatter.format(dt)
        #expect(formatted == "2024-01-01T00:00:00Z[Asia/Jerusalem][u-ca=hebrew]")
    }
}

@Suite("RFC_9557.Formatter - Round-trip")
struct FormatterRoundTripTests {
    @Test("Round-trip: parse then format")
    func roundTrip() throws {
        let original = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
        let dt = try RFC_9557.Parser.parse(original)
        let formatted = RFC_9557.Formatter.format(dt)

        #expect(formatted == original)
    }

    @Test("Round-trip with calendar")
    func roundTripWithCalendar() throws {
        let original = "2024-01-01T00:00:00Z[Europe/Paris][u-ca=gregory]"
        let dt = try RFC_9557.Parser.parse(original)
        let formatted = RFC_9557.Formatter.format(dt)

        #expect(formatted == original)
    }
}
