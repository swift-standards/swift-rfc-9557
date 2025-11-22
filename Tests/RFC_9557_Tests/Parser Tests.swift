// Parser Tests.swift
// swift-rfc-9557
//
// Tests for RFC_9557.Parser

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Parser - Basic Parsing")
struct ParserBasicTests {
    @Test("Parse RFC 3339 without suffix")
    func parseWithoutSuffix() throws {
        let input = "1996-12-19T16:39:57-08:00"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.base.time.year.value == 1996)
        #expect(dt.base.offset == .offset(seconds: -28800))
        #expect(dt.suffix == nil)
    }

    @Test("Parse with IANA time zone")
    func parseWithIANATimeZone() throws {
        let input = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.base.time.year.value == 1996)
        #expect(dt.suffix?.timeZone == .iana("America/Los_Angeles", critical: false))
    }

    @Test("Parse with critical IANA time zone")
    func parseWithCriticalTimeZone() throws {
        let input = "1996-12-19T16:39:57-08:00[!America/Los_Angeles]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.timeZone == .iana("America/Los_Angeles", critical: true))
        #expect(dt.suffix?.timeZone?.isCritical == true)
    }

    @Test("Parse with offset time zone")
    func parseWithOffsetTimeZone() throws {
        let input = "2024-01-01T00:00:00+00:00[+08:45]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.timeZone == .offset("+08:45", critical: false))
    }

    @Test("Parse with calendar system")
    func parseWithCalendar() throws {
        let input = "2024-01-01T00:00:00Z[Asia/Jerusalem][u-ca=hebrew]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.timeZone == .iana("Asia/Jerusalem", critical: false))
        #expect(dt.suffix?.calendar == "hebrew")
    }

    @Test("Parse with multiple suffix tags")
    func parseWithMultipleTags() throws {
        let input = "2024-01-01T00:00:00Z[Europe/Paris][u-ca=gregory]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.timeZone == .iana("Europe/Paris", critical: false))
        #expect(dt.suffix?.calendar == "gregory")
    }
}

@Suite("RFC_9557.Parser - Examples from RFC")
struct ParserRFCExamplesTests {
    @Test("Example 1: Basic timestamp with time zone")
    func example1() throws {
        let input = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.base.time.year.value == 1996)
        #expect(dt.base.time.month.value == 12)
        #expect(dt.base.time.day.value == 19)
        #expect(dt.suffix?.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("Example 2: With calendar system")
    func example2() throws {
        let input = "2022-07-08T00:14:07Z[Europe/London][u-ca=iso8601]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.base.time.year.value == 2022)
        #expect(dt.suffix?.timeZone?.identifier == "Europe/London")
        #expect(dt.suffix?.calendar == "iso8601")
    }
}
