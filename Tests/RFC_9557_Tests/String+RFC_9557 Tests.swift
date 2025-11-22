// String+RFC_9557 Tests.swift
// swift-rfc-9557
//
// Tests for String extensions

import Testing
@testable import RFC_9557

@Suite("String+RFC_9557 - Parsing")
struct StringExtensionParsingTests {
    @Test("Parse from String")
    func parseFromString() throws {
        let timestamp = "1996-12-19T16:39:57-08:00[America/Los_Angeles]"
        let dt = try timestamp.rfc9557ExtendedDateTime()

        #expect(dt.base.time.year.value == 1996)
        #expect(dt.suffix?.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("Parse from Substring")
    func parseFromSubstring() throws {
        let full = "Timestamp: 1996-12-19T16:39:57-08:00[America/Los_Angeles] end"
        let startIndex = full.index(full.startIndex, offsetBy: 11)
        let endIndex = full.index(startIndex, offsetBy: 48)
        let substring = full[startIndex..<endIndex]

        let dt = try substring.rfc9557ExtendedDateTime()

        #expect(dt.base.time.year.value == 1996)
        #expect(dt.suffix?.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("Parse plain RFC 3339 via String extension")
    func parsePlainRFC3339() throws {
        let timestamp = "1996-12-19T16:39:57-08:00"
        let dt = try timestamp.rfc9557ExtendedDateTime()

        #expect(dt.base.time.year.value == 1996)
        #expect(dt.suffix == nil)
    }
}

@Suite("String+RFC_9557 - Experimental Tags")
struct StringExtensionExperimentalTests {
    @Test("Normal parse rejects experimental tags")
    func normalParseRejectsExperimental() {
        let timestamp = "2022-07-08T00:14:07Z[_foo=bar]"
        #expect(throws: RFC_9557.ParserError.self) {
            try timestamp.rfc9557ExtendedDateTime()
        }
    }

    @Test("Experimental parse accepts experimental tags")
    func experimentalParseAcceptsExperimental() throws {
        let timestamp = "2022-07-08T00:14:07Z[_foo=bar]"
        let dt = try timestamp.rfc9557ExtendedDateTimeAllowingExperimental()

        #expect(dt.suffix?.tags.count == 1)
        #expect(dt.suffix?.tags.first?.key == "_foo")
        #expect(dt.suffix?.tags.first?.isExperimental == true)
    }

    @Test("Experimental parse from Substring")
    func experimentalParseFromSubstring() throws {
        let full = "Data: 2022-07-08T00:14:07Z[_foo=bar] more"
        let startIndex = full.index(full.startIndex, offsetBy: 6)
        let endIndex = full.index(startIndex, offsetBy: 35)
        let substring = full[startIndex..<endIndex]

        let dt = try substring.rfc9557ExtendedDateTimeAllowingExperimental()

        #expect(dt.suffix?.tags.first?.key == "_foo")
    }
}

@Suite("String+RFC_9557 - Error Propagation")
struct StringExtensionErrorTests {
    @Test("Propagate parse errors")
    func propagateParseErrors() {
        #expect(throws: RFC_9557.ParserError.invalidSuffixKey("U-CA")) {
            try "2022-07-08T00:14:07Z[U-CA=hebrew]".rfc9557ExtendedDateTime()
        }

        #expect(throws: RFC_9557.ParserError.multipleTimeZones) {
            try "2022-07-08T00:14:07Z[Europe/Paris][America/New_York]".rfc9557ExtendedDateTime()
        }

        #expect(throws: RFC_9557.ParserError.emptyTag) {
            try "2022-07-08T00:14:07Z[]".rfc9557ExtendedDateTime()
        }
    }
}
