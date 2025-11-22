// EdgeCases Tests.swift
// swift-rfc-9557
//
// Tests for RFC 9557 edge cases

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Parser - Edge Cases: Time Zones")
struct EdgeCasesTimeZoneTests {
    @Test("IANA time zone case sensitivity")
    func ianaTimeZoneCaseSensitivity() throws {
        // Time zone names are case-sensitive per spec
        let dt1 = try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[Europe/Paris]")
        let dt2 = try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[europe/paris]")

        #expect(dt1.suffix?.timeZone?.identifier == "Europe/Paris")
        #expect(dt2.suffix?.timeZone?.identifier == "europe/paris")
        #expect(dt1.suffix?.timeZone != dt2.suffix?.timeZone)
    }

    @Test("Offset time zones")
    func offsetTimeZones() throws {
        let inputs = [
            ("2022-07-08T00:14:07+08:45[+08:45]", "+08:45"),
            ("2022-07-08T00:14:07-05:00[-05:00]", "-05:00"),
            ("2022-07-08T00:14:07+00:00[+00:00]", "+00:00")
        ]

        for (input, expectedOffset) in inputs {
            let dt = try RFC_9557.Parser.parse(input)
            if case .offset(let offset, _) = dt.suffix?.timeZone {
                #expect(offset == expectedOffset)
            } else {
                Issue.record("Expected offset time zone")
            }
        }
    }

    @Test("Critical time zones")
    func criticalTimeZones() throws {
        let dt = try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[!Europe/London]")
        #expect(dt.suffix?.timeZone?.isCritical == true)
    }

    @Test("Complex IANA time zone names")
    func complexIANANames() throws {
        let names = [
            "America/Argentina/Buenos_Aires",
            "America/Indiana/Indianapolis",
            "America/North_Dakota/New_Salem",
            "Etc/GMT+5",
            "Etc/GMT-8"
        ]

        for name in names {
            let input = "2022-07-08T00:14:07Z[\(name)]"
            let dt = try RFC_9557.Parser.parse(input)
            #expect(dt.suffix?.timeZone?.identifier == name)
        }
    }
}

@Suite("RFC_9557.Parser - Edge Cases: Calendar Systems")
struct EdgeCasesCalendarTests {
    @Test("Common calendar systems")
    func commonCalendarSystems() throws {
        let calendars = ["hebrew", "islamic", "buddhist", "chinese", "japanese", "gregory", "iso8601"]

        for calendar in calendars {
            let input = "2022-07-08T00:14:07Z[u-ca=\(calendar)]"
            let dt = try RFC_9557.Parser.parse(input)
            #expect(dt.suffix?.calendar == calendar)
        }
    }

    @Test("Calendar value case sensitivity")
    func calendarCaseSensitivity() throws {
        // Values are case-sensitive per spec
        let dt1 = try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[u-ca=Hebrew]")
        let dt2 = try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[u-ca=hebrew]")

        #expect(dt1.suffix?.calendar == "Hebrew")
        #expect(dt2.suffix?.calendar == "hebrew")
        #expect(dt1.suffix?.calendar != dt2.suffix?.calendar)
    }
}

@Suite("RFC_9557.Parser - Edge Cases: Complex Suffixes")
struct EdgeCasesComplexSuffixTests {
    @Test("Time zone + calendar")
    func timeZoneAndCalendar() throws {
        let input = "1996-12-19T16:39:57-08:00[America/Los_Angeles][u-ca=hebrew]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.timeZone?.identifier == "America/Los_Angeles")
        #expect(dt.suffix?.calendar == "hebrew")
    }

    @Test("Time zone + calendar + custom tags")
    func timeZoneCalendarCustomTags() throws {
        let input = "2022-07-08T00:14:07Z[Europe/Paris][u-ca=gregory][foo=bar][baz=qux]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.timeZone?.identifier == "Europe/Paris")
        #expect(dt.suffix?.calendar == "gregory")
        #expect(dt.suffix?.tags.count == 2)
    }

    @Test("Multi-value suffix tags")
    func multiValueSuffixTags() throws {
        let input = "2022-07-08T00:14:07Z[foo=bar-baz-qux]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.tags.count == 1)
        #expect(dt.suffix?.tags.first?.values == ["bar", "baz", "qux"])
    }

    @Test("Critical and elective tags mixed")
    func criticalAndElectiveMixed() throws {
        let input = "2022-07-08T00:14:07Z[!u-ca=hebrew][foo=bar]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.calendar == "hebrew")
        #expect(dt.suffix?.tags.count == 1)
        #expect(dt.suffix?.tags.first?.critical == false)
    }

    @Test("Maximum complexity suffix")
    func maxComplexitySuffix() throws {
        let input = "1996-12-19T16:39:57-08:00[!America/Los_Angeles][!u-ca=hebrew][foo=bar-baz][qux=test]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.suffix?.timeZone?.isCritical == true)
        #expect(dt.suffix?.calendar == "hebrew")
        #expect(dt.suffix?.tags.count == 2)
        #expect(dt.suffix?.hasCriticalComponents == true)
    }
}

@Suite("RFC_9557.Parser - Edge Cases: RFC 3339 Compatibility")
struct EdgeCasesRFC3339CompatibilityTests {
    @Test("Plain RFC 3339 timestamps (backward compatible)")
    func plainRFC3339() throws {
        let inputs = [
            "1996-12-19T16:39:57-08:00",
            "2022-07-08T00:14:07Z",
            "2022-07-08T00:14:07+00:00",
            "1985-04-12T23:20:50.52Z"
        ]

        for input in inputs {
            let dt = try RFC_9557.Parser.parse(input)
            #expect(dt.suffix == nil)
        }
    }

    @Test("Fractional seconds with suffix")
    func fractionalSecondsWithSuffix() throws {
        let input = "1985-04-12T23:20:50.52Z[America/New_York]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.base.time.second.value == 50)
        // Fractional seconds are parsed by RFC 3339 parser
        // Just verify the suffix is correct for now
        #expect(dt.suffix?.timeZone?.identifier == "America/New_York")
    }

    @Test("Leap second with suffix")
    func leapSecondWithSuffix() throws {
        let input = "1990-12-31T23:59:60Z[UTC]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.base.time.second.value == 60)
        #expect(dt.suffix?.timeZone?.identifier == "UTC")
    }

    @Test("Z offset with time zone (no inconsistency)")
    func zOffsetWithTimeZone() throws {
        // Per spec: Z indicates UTC time known, local offset unknown
        // Adding a time zone is not an inconsistency
        let input = "2022-07-08T00:14:07Z[Europe/Paris]"
        let dt = try RFC_9557.Parser.parse(input)

        #expect(dt.base.offset == .utc)
        #expect(dt.suffix?.timeZone?.identifier == "Europe/Paris")
    }
}

@Suite("RFC_9557.Parser - Edge Cases: Minimal Inputs")
struct EdgeCasesMinimalInputTests {
    @Test("Single character time zone")
    func singleCharTimeZone() throws {
        let input = "2022-07-08T00:14:07Z[Z]"
        let dt = try RFC_9557.Parser.parse(input)
        #expect(dt.suffix?.timeZone?.identifier == "Z")
    }

    @Test("Single character key and value")
    func singleCharKeyValue() throws {
        let input = "2022-07-08T00:14:07Z[a=b]"
        let dt = try RFC_9557.Parser.parse(input)
        #expect(dt.suffix?.tags.first?.key == "a")
        #expect(dt.suffix?.tags.first?.values == ["b"])
    }

    @Test("Underscore-only experimental key")
    func underscoreOnlyKey() throws {
        let input = "2022-07-08T00:14:07Z[_=foo]"
        let dt = try RFC_9557.Parser.parseAllowingExperimental(input)
        #expect(dt.suffix?.tags.first?.key == "_")
        #expect(dt.suffix?.tags.first?.isExperimental == true)
    }
}
