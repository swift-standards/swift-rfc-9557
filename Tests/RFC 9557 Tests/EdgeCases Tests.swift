// EdgeCases Tests.swift
// swift-rfc-9557
//
// Tests for RFC 9557 edge cases

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Timestamp - Edge Cases: Time Zones")
struct EdgeCasesTimeZoneTests {
    @Test("IANA time zone case sensitivity")
    func ianaTimeZoneCaseSensitivity() throws {
        // Time zone names are case-sensitive per spec
        let ts1 = try RFC_9557.Timestamp("2022-07-08T00:14:07Z[Europe/Paris]")
        let ts2 = try RFC_9557.Timestamp("2022-07-08T00:14:07Z[europe/paris]")

        #expect(ts1.suffix?.timeZone?.identifier == "Europe/Paris")
        #expect(ts2.suffix?.timeZone?.identifier == "europe/paris")
        #expect(ts1.suffix?.timeZone != ts2.suffix?.timeZone)
    }

    @Test("Offset time zones")
    func offsetTimeZones() throws {
        let inputs = [
            ("2022-07-08T00:14:07+08:45[+08:45]", "+08:45"),
            ("2022-07-08T00:14:07-05:00[-05:00]", "-05:00"),
            ("2022-07-08T00:14:07+00:00[+00:00]", "+00:00")
        ]

        for (input, expectedOffset) in inputs {
            let ts = try RFC_9557.Timestamp(input)
            if case .offset(let offset, _) = ts.suffix?.timeZone {
                #expect(offset == expectedOffset)
            } else {
                Issue.record("Expected offset time zone")
            }
        }
    }

    @Test("Critical time zones")
    func criticalTimeZones() throws {
        let ts = try RFC_9557.Timestamp("2022-07-08T00:14:07Z[!Europe/London]")
        #expect(ts.suffix?.timeZone?.isCritical == true)
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
            let ts = try RFC_9557.Timestamp(input)
            #expect(ts.suffix?.timeZone?.identifier == name)
        }
    }
}

@Suite("RFC_9557.Timestamp - Edge Cases: Calendar Systems")
struct EdgeCasesCalendarTests {
    @Test("Common calendar systems")
    func commonCalendarSystems() throws {
        let calendars = ["hebrew", "islamic", "buddhist", "chinese", "japanese", "gregory", "iso8601"]

        for calendar in calendars {
            let input = "2022-07-08T00:14:07Z[u-ca=\(calendar)]"
            let ts = try RFC_9557.Timestamp(input)
            #expect(ts.suffix?.calendar == calendar)
        }
    }

    @Test("Calendar value case sensitivity")
    func calendarCaseSensitivity() throws {
        // Values are case-sensitive per spec
        let ts1 = try RFC_9557.Timestamp("2022-07-08T00:14:07Z[u-ca=Hebrew]")
        let ts2 = try RFC_9557.Timestamp("2022-07-08T00:14:07Z[u-ca=hebrew]")

        #expect(ts1.suffix?.calendar == "Hebrew")
        #expect(ts2.suffix?.calendar == "hebrew")
        #expect(ts1.suffix?.calendar != ts2.suffix?.calendar)
    }
}

@Suite("RFC_9557.Timestamp - Edge Cases: Complex Suffixes")
struct EdgeCasesComplexSuffixTests {
    @Test("Time zone + calendar")
    func timeZoneAndCalendar() throws {
        let input = "1996-12-19T16:39:57-08:00[America/Los_Angeles][u-ca=hebrew]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.timeZone?.identifier == "America/Los_Angeles")
        #expect(ts.suffix?.calendar == "hebrew")
    }

    @Test("Time zone + calendar + custom tags")
    func timeZoneCalendarCustomTags() throws {
        let input = "2022-07-08T00:14:07Z[Europe/Paris][u-ca=gregory][foo=bar][baz=qux]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.timeZone?.identifier == "Europe/Paris")
        #expect(ts.suffix?.calendar == "gregory")
        #expect(ts.suffix?.tags.count == 2)
    }

    @Test("Multi-value suffix tags")
    func multiValueSuffixTags() throws {
        let input = "2022-07-08T00:14:07Z[foo=bar-baz-qux]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.tags.count == 1)
        #expect(ts.suffix?.tags.first?.values == ["bar", "baz", "qux"])
    }

    @Test("Critical and elective tags mixed")
    func criticalAndElectiveMixed() throws {
        let input = "2022-07-08T00:14:07Z[!u-ca=hebrew][foo=bar]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.calendar == "hebrew")
        #expect(ts.suffix?.tags.count == 1)
        #expect(ts.suffix?.tags.first?.critical == false)
    }

    @Test("Maximum complexity suffix")
    func maxComplexitySuffix() throws {
        let input = "1996-12-19T16:39:57-08:00[!America/Los_Angeles][!u-ca=hebrew][foo=bar-baz][qux=test]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.suffix?.timeZone?.isCritical == true)
        #expect(ts.suffix?.calendar == "hebrew")
        #expect(ts.suffix?.tags.count == 2)
        #expect(ts.suffix?.hasCriticalComponents == true)
    }
}

@Suite("RFC_9557.Timestamp - Edge Cases: RFC 3339 Compatibility")
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
            let ts = try RFC_9557.Timestamp(input)
            #expect(ts.suffix == nil)
        }
    }

    @Test("Fractional seconds with suffix")
    func fractionalSecondsWithSuffix() throws {
        let input = "1985-04-12T23:20:50.52Z[America/New_York]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.base.time.second.value == 50)
        #expect(ts.suffix?.timeZone?.identifier == "America/New_York")
    }

    @Test("Leap second with suffix")
    func leapSecondWithSuffix() throws {
        let input = "1990-12-31T23:59:60Z[UTC]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.base.time.second.value == 60)
        #expect(ts.suffix?.timeZone?.identifier == "UTC")
    }

    @Test("Z offset with time zone (no inconsistency)")
    func zOffsetWithTimeZone() throws {
        // Per spec: Z indicates UTC time known, local offset unknown
        // Adding a time zone is not an inconsistency
        let input = "2022-07-08T00:14:07Z[Europe/Paris]"
        let ts = try RFC_9557.Timestamp(input)

        #expect(ts.base.offset == .utc)
        #expect(ts.suffix?.timeZone?.identifier == "Europe/Paris")
    }
}

@Suite("RFC_9557.Timestamp - Edge Cases: Minimal Inputs")
struct EdgeCasesMinimalInputTests {
    @Test("Single character time zone")
    func singleCharTimeZone() throws {
        let input = "2022-07-08T00:14:07Z[Z]"
        let ts = try RFC_9557.Timestamp(input)
        #expect(ts.suffix?.timeZone?.identifier == "Z")
    }

    @Test("Single character key and value")
    func singleCharKeyValue() throws {
        let input = "2022-07-08T00:14:07Z[a=b]"
        let ts = try RFC_9557.Timestamp(input)
        #expect(ts.suffix?.tags.first?.key == "a")
        #expect(ts.suffix?.tags.first?.values == ["b"])
    }
}
