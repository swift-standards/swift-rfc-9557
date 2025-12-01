// Suffix Tests.swift
// swift-rfc-9557
//
// Tests for RFC_9557.Suffix

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Suffix - Error Handling: Critical Tags")
struct SuffixErrorCriticalTagTests {
    @Test("Reject critical unknown tags")
    func rejectCriticalUnknownTags() {
        let input = "2022-07-08T00:14:07Z[!knort=blargel]"
        #expect(throws: RFC_9557.Timestamp.Error.self) {
            try RFC_9557.Timestamp(input)
        }
    }

    @Test("Accept elective unknown tags")
    func acceptElectiveUnknownTags() throws {
        let input = "2022-07-08T00:14:07Z[knort=blargel]"
        let ts = try RFC_9557.Timestamp(input)
        #expect(ts.suffix?.tags.count == 1)
        #expect(ts.suffix?.tags.first?.key == "knort")
    }

    @Test("Reject critical experimental tags")
    func rejectCriticalExperimentalTags() {
        let input = "[!_foo=bar]"
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array(input.utf8))
        }
    }

    @Test("Accept critical registered tags (u-ca)")
    func acceptCriticalRegisteredTags() throws {
        let input = "2022-07-08T00:14:07Z[!u-ca=hebrew]"
        let ts = try RFC_9557.Timestamp(input)
        #expect(ts.suffix?.calendar == "hebrew")
    }
}

@Suite("RFC_9557.Suffix - Error Handling: Experimental Tags")
struct SuffixErrorExperimentalTagTests {
    @Test("Reject experimental tags in normal parse")
    func rejectExperimentalInNormalParse() {
        let input = "[_foo=bar]"
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array(input.utf8))
        }
    }
}

@Suite("RFC_9557.Suffix - Error Handling: Invalid Formats")
struct SuffixErrorInvalidFormatTests {
    @Test("Reject malformed brackets: unclosed")
    func rejectUnclosedBracket() {
        let input = "[Europe/Paris"
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array(input.utf8))
        }
    }

    @Test("Reject empty tags")
    func rejectEmptyTags() {
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array("[]".utf8))
        }
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array("[!]".utf8))
        }
    }

    @Test("Reject multiple time zones")
    func rejectMultipleTimeZones() {
        let input = "[Europe/Paris][America/New_York]"
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array(input.utf8))
        }
    }

    @Test("Reject invalid suffix keys")
    func rejectInvalidKeys() {
        // Uppercase
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array("[U-CA=hebrew]".utf8))
        }

        // Starts with digit
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array("[1foo=bar]".utf8))
        }
    }

    @Test("Reject invalid suffix values")
    func rejectInvalidValues() {
        // Special characters
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array("[u-ca=foo@bar]".utf8))
        }
    }

    @Test("Reject invalid time zone names")
    func rejectInvalidTimeZoneNames() {
        // Dot-only parts
        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array("[.]".utf8))
        }

        #expect(throws: RFC_9557.Suffix.Error.self) {
            try RFC_9557.Suffix(ascii: Array("[..]".utf8))
        }
    }
}

@Suite("RFC_9557.Suffix - Error Handling: Duplicate Keys")
struct SuffixErrorDuplicateKeyTests {
    @Test("Duplicate u-ca tags: use first occurrence")
    func duplicateCalendarUseFirst() throws {
        let input = "2022-07-08T00:14:07Z[u-ca=chinese][u-ca=japanese]"
        let ts = try RFC_9557.Timestamp(input)
        #expect(ts.suffix?.calendar == "chinese")
    }

    @Test("Duplicate elective tags: use first occurrence")
    func duplicateTagsUseFirst() throws {
        let input = "2022-07-08T00:14:07Z[foo=bar][foo=baz]"
        let ts = try RFC_9557.Timestamp(input)
        #expect(ts.suffix?.tags.count == 1)
        #expect(ts.suffix?.tags.first?.values == ["bar"])
    }

    @Test("Mixed duplicate and unique tags")
    func mixedDuplicateUniqueTags() throws {
        let input = "2022-07-08T00:14:07Z[foo=a][bar=b][foo=c][baz=d]"
        let ts = try RFC_9557.Timestamp(input)
        #expect(ts.suffix?.tags.count == 3)

        // foo should be first occurrence only
        let fooTag = ts.suffix?.tags.first { $0.key == "foo" }
        #expect(fooTag?.values == ["a"])

        // bar and baz should be present
        #expect(ts.suffix?.tags.contains { $0.key == "bar" } == true)
        #expect(ts.suffix?.tags.contains { $0.key == "baz" } == true)
    }
}
