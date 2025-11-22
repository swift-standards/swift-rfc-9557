// ParserError Tests.swift
// swift-rfc-9557
//
// Tests for RFC_9557.Parser error handling

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Parser - Error Handling: Critical Tags")
struct ParserErrorCriticalTagTests {
    @Test("Reject critical unknown tags")
    func rejectCriticalUnknownTags() {
        let input = "2022-07-08T00:14:07Z[!knort=blargel]"
        #expect(throws: RFC_9557.ParserError.criticalTagNotSupported(key: "knort")) {
            try RFC_9557.Parser.parse(input)
        }
    }

    @Test("Accept elective unknown tags")
    func acceptElectiveUnknownTags() throws {
        let input = "2022-07-08T00:14:07Z[knort=blargel]"
        let dt = try RFC_9557.Parser.parse(input)
        #expect(dt.suffix?.tags.count == 1)
        #expect(dt.suffix?.tags.first?.key == "knort")
    }

    @Test("Reject critical experimental tags")
    func rejectCriticalExperimentalTags() {
        let input = "2022-07-08T00:14:07Z[!_foo=bar]"
        #expect(throws: RFC_9557.ParserError.criticalExperimentalTag(key: "_foo")) {
            try RFC_9557.Parser.parse(input)
        }
    }

    @Test("Accept critical registered tags (u-ca)")
    func acceptCriticalRegisteredTags() throws {
        let input = "2022-07-08T00:14:07Z[!u-ca=hebrew]"
        let dt = try RFC_9557.Parser.parse(input)
        #expect(dt.suffix?.calendar == "hebrew")
    }
}

@Suite("RFC_9557.Parser - Error Handling: Experimental Tags")
struct ParserErrorExperimentalTagTests {
    @Test("Reject experimental tags in normal parse")
    func rejectExperimentalInNormalParse() {
        let input = "2022-07-08T00:14:07Z[_foo=bar]"
        #expect(throws: RFC_9557.ParserError.experimentalTagInInterchange(key: "_foo")) {
            try RFC_9557.Parser.parse(input)
        }
    }

    @Test("Accept experimental tags with parseAllowingExperimental")
    func acceptExperimentalInAllowingParse() throws {
        let input = "2022-07-08T00:14:07Z[_foo=bar]"
        let dt = try RFC_9557.Parser.parseAllowingExperimental(input)
        #expect(dt.suffix?.tags.count == 1)
        #expect(dt.suffix?.tags.first?.key == "_foo")
        #expect(dt.suffix?.tags.first?.isExperimental == true)
    }

    @Test("Multiple experimental tags")
    func multipleExperimentalTags() throws {
        let input = "1996-12-19T16:39:57-08:00[_foo=bar][_baz=bat]"
        let dt = try RFC_9557.Parser.parseAllowingExperimental(input)
        #expect(dt.suffix?.tags.count == 2)
        #expect(dt.suffix?.tags[0].key == "_foo")
        #expect(dt.suffix?.tags[1].key == "_baz")
    }
}

@Suite("RFC_9557.Parser - Error Handling: Invalid Formats")
struct ParserErrorInvalidFormatTests {
    @Test("Reject malformed brackets: unclosed")
    func rejectUnclosedBracket() {
        let input = "2022-07-08T00:14:07Z[Europe/Paris"
        #expect(throws: RFC_9557.ParserError.malformedBrackets("Unclosed bracket")) {
            try RFC_9557.Parser.parse(input)
        }
    }

    @Test("Reject empty tags")
    func rejectEmptyTags() {
        #expect(throws: RFC_9557.ParserError.emptyTag) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[]")
        }
        #expect(throws: RFC_9557.ParserError.emptyTag) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[!]")
        }
    }

    @Test("Reject multiple time zones")
    func rejectMultipleTimeZones() {
        let input = "2022-07-08T00:14:07Z[Europe/Paris][America/New_York]"
        #expect(throws: RFC_9557.ParserError.multipleTimeZones) {
            try RFC_9557.Parser.parse(input)
        }
    }

    @Test("Reject invalid suffix keys")
    func rejectInvalidKeys() {
        // Uppercase
        #expect(throws: RFC_9557.ParserError.invalidSuffixKey("U-CA")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[U-CA=hebrew]")
        }

        // Starts with digit
        #expect(throws: RFC_9557.ParserError.invalidSuffixKey("1foo")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[1foo=bar]")
        }

        // Invalid characters
        #expect(throws: RFC_9557.ParserError.invalidSuffixKey("foo.bar")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[foo.bar=baz]")
        }
    }

    @Test("Reject invalid suffix values")
    func rejectInvalidValues() {
        // Special characters
        #expect(throws: RFC_9557.ParserError.invalidSuffixValue("foo@bar")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[u-ca=foo@bar]")
        }

        // Empty value
        #expect(throws: RFC_9557.ParserError.invalidSuffixValue("")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[u-ca=]")
        }
    }

    @Test("Reject invalid time zone names")
    func rejectInvalidTimeZoneNames() {
        // Dot-only parts
        #expect(throws: RFC_9557.ParserError.invalidTimeZoneName(".")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[.]")
        }

        #expect(throws: RFC_9557.ParserError.invalidTimeZoneName("..")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[..]")
        }

        #expect(throws: RFC_9557.ParserError.invalidTimeZoneName("America/.")) {
            try RFC_9557.Parser.parse("2022-07-08T00:14:07Z[America/.]")
        }
    }
}

@Suite("RFC_9557.Parser - Error Handling: Duplicate Keys")
struct ParserErrorDuplicateKeyTests {
    @Test("Duplicate u-ca tags: use first occurrence")
    func duplicateCalendarUseFirst() throws {
        let input = "2022-07-08T00:14:07Z[u-ca=chinese][u-ca=japanese]"
        let dt = try RFC_9557.Parser.parse(input)
        #expect(dt.suffix?.calendar == "chinese")
    }

    @Test("Duplicate elective tags: use first occurrence")
    func duplicateTagsUseFirst() throws {
        let input = "2022-07-08T00:14:07Z[foo=bar][foo=baz]"
        let dt = try RFC_9557.Parser.parse(input)
        #expect(dt.suffix?.tags.count == 1)
        #expect(dt.suffix?.tags.first?.values == ["bar"])
    }

    @Test("Mixed duplicate and unique tags")
    func mixedDuplicateUniqueTags() throws {
        let input = "2022-07-08T00:14:07Z[foo=a][bar=b][foo=c][baz=d]"
        let dt = try RFC_9557.Parser.parse(input)
        #expect(dt.suffix?.tags.count == 3)

        // foo should be first occurrence only
        let fooTag = dt.suffix?.tags.first { $0.key == "foo" }
        #expect(fooTag?.values == ["a"])

        // bar and baz should be present
        #expect(dt.suffix?.tags.contains { $0.key == "bar" } == true)
        #expect(dt.suffix?.tags.contains { $0.key == "baz" } == true)
    }
}
