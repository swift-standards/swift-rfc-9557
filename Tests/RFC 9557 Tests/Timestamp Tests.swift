// Timestamp Tests.swift
// swift-rfc-9557
//
// Tests for RFC_9557.Timestamp

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Timestamp - Basic Parsing")
struct TimestampBasicTests {
    @Test("Parse RFC 3339 without suffix")
    func parseWithoutSuffix() throws {
        let input = "1996-12-19T16:39:57-08:00"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.base.time.year == 1996)
        #expect(ts.base.offset == .offset(seconds: -28800))
        #expect(ts.suffix == nil)
    }

    @Test("Parse with IANA time zone")
    func parseWithIANATimeZone() throws {
        let input = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.base.time.year == 1996)
        #expect(ts.suffix?.timeZone == .iana("America/Los_Angeles", critical: false))
    }

    @Test("Parse with critical IANA time zone")
    func parseWithCriticalTimeZone() throws {
        let input = "1996-12-19T16:39:57-08:00[!America/Los_Angeles]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.timeZone == .iana("America/Los_Angeles", critical: true))
        #expect(ts.suffix?.timeZone?.isCritical == true)
    }

    @Test("Parse with offset time zone")
    func parseWithOffsetTimeZone() throws {
        let input = "2024-01-01T00:00:00+00:00[+08:45]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.timeZone == .offset("+08:45", critical: false))
    }

    @Test("Parse with calendar system")
    func parseWithCalendar() throws {
        let input = "2024-01-01T00:00:00Z[Asia/Jerusalem][u-ca=hebrew]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.timeZone == .iana("Asia/Jerusalem", critical: false))
        #expect(ts.suffix?.calendar == "hebrew")
    }

    @Test("Parse with multiple suffix tags")
    func parseWithMultipleTags() throws {
        let input = "2024-01-01T00:00:00Z[Europe/Paris][u-ca=gregory]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.timeZone == .iana("Europe/Paris", critical: false))
        #expect(ts.suffix?.calendar == "gregory")
    }
}

@Suite("RFC_9557.Timestamp - Examples from RFC")
struct TimestampRFCExamplesTests {
    @Test("Example 1: Basic timestamp with time zone")
    func example1() throws {
        let input = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.base.time.year == 1996)
        #expect(ts.base.time.month == 12)
        #expect(ts.base.time.day == 19)
        #expect(ts.suffix?.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("Example 2: With calendar system")
    func example2() throws {
        let input = "2022-07-08T00:14:07Z[Europe/London][u-ca=iso8601]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.base.time.year == 2022)
        #expect(ts.suffix?.timeZone?.identifier == "Europe/London")
        #expect(ts.suffix?.calendar == "iso8601")
    }
}

@Suite("RFC_9557.Timestamp - Serialization")
struct TimestampSerializationTests {
    @Test("Serialize without suffix")
    func serializeWithoutSuffix() throws {
        let time = try Time(year: 1996, month: 12, day: 19, hour: 16, minute: 39, second: 57)
        let base = RFC_3339.DateTime(time: time, offset: .offset(seconds: -28800))
        let ts = RFC_9557.Timestamp(base: base)

        let formatted = String(ts)
        #expect(formatted == "1996-12-19T16:39:57-08:00")
    }

    @Test("Serialize with IANA time zone")
    func serializeWithIANATimeZone() throws {
        let time = try Time(year: 1996, month: 12, day: 19, hour: 16, minute: 39, second: 57)
        let base = RFC_3339.DateTime(time: time, offset: .offset(seconds: -28800))
        let suffix = RFC_9557.Suffix(timeZone: .iana("America/Los_Angeles", critical: false))
        let ts = RFC_9557.Timestamp(base: base, suffix: suffix)

        let formatted = String(ts)
        #expect(formatted == "1996-12-19T16:39:57-08:00[America/Los_Angeles]")
    }

    @Test("Serialize with critical time zone")
    func serializeWithCriticalTimeZone() throws {
        let time = try Time(year: 1996, month: 12, day: 19, hour: 16, minute: 39, second: 57)
        let base = RFC_3339.DateTime(time: time, offset: .offset(seconds: -28800))
        let suffix = RFC_9557.Suffix(timeZone: .iana("America/Los_Angeles", critical: true))
        let ts = RFC_9557.Timestamp(base: base, suffix: suffix)

        let formatted = String(ts)
        #expect(formatted == "1996-12-19T16:39:57-08:00[!America/Los_Angeles]")
    }

    @Test("Serialize with calendar system")
    func serializeWithCalendar() throws {
        let time = try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        let base = RFC_3339.DateTime(time: time, offset: .utc)
        let suffix = RFC_9557.Suffix(
            timeZone: .iana("Asia/Jerusalem", critical: false),
            calendar: "hebrew"
        )
        let ts = RFC_9557.Timestamp(base: base, suffix: suffix)

        let formatted = String(ts)
        #expect(formatted == "2024-01-01T00:00:00Z[Asia/Jerusalem][u-ca=hebrew]")
    }

    @Test("Round-trip: parse then serialize")
    func roundTrip() throws {
        let original = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
        let ts = try RFC_9557.Timestamp(original)
        let serialized = String(ts)

        #expect(serialized == original)
    }

    @Test("Round-trip with calendar")
    func roundTripWithCalendar() throws {
        let original = "2024-01-01T00:00:00Z[Europe/Paris][u-ca=gregory]"
        let ts = try RFC_9557.Timestamp(original)
        let serialized = String(ts)

        #expect(serialized == original)
    }
}
