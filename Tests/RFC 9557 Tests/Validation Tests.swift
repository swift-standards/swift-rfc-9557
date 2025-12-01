// Validation Tests.swift
// swift-rfc-9557
//
// Tests for RFC_9557.Validation

import Testing
@testable import RFC_9557

@Suite("RFC_9557.Validation - Suffix Key Format")
struct ValidationSuffixKeyTests {
    @Test("Valid lowercase keys")
    func validLowercaseKeys() throws {
        try RFC_9557.Validation.validateSuffixKey("u-ca")
        try RFC_9557.Validation.validateSuffixKey("foo")
        try RFC_9557.Validation.validateSuffixKey("foo-bar")
        try RFC_9557.Validation.validateSuffixKey("key123")
        try RFC_9557.Validation.validateSuffixKey("a")
    }

    @Test("Valid experimental keys (underscore prefix)")
    func validExperimentalKeys() throws {
        try RFC_9557.Validation.validateSuffixKey("_foo")
        try RFC_9557.Validation.validateSuffixKey("_bar-baz")
        try RFC_9557.Validation.validateSuffixKey("_test123")
        try RFC_9557.Validation.validateSuffixKey("_")
    }

    @Test("Invalid: uppercase letters")
    func invalidUppercase() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("U-CA")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("Foo")
        }
    }

    @Test("Invalid: starts with digit")
    func invalidStartsWithDigit() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("1foo")
        }
    }

    @Test("Invalid: starts with hyphen")
    func invalidStartsWithHyphen() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("-foo")
        }
    }

    @Test("Invalid: contains invalid characters")
    func invalidCharacters() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("foo@bar")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("foo.bar")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("foo bar")
        }
    }

    @Test("Invalid: empty key")
    func invalidEmpty() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixKey("")
        }
    }

    @Test("Experimental key detection")
    func experimentalKeyDetection() {
        #expect(RFC_9557.Validation.isExperimentalKey("_foo"))
        #expect(RFC_9557.Validation.isExperimentalKey("_"))
        #expect(!RFC_9557.Validation.isExperimentalKey("foo"))
        #expect(!RFC_9557.Validation.isExperimentalKey("u-ca"))
    }
}

@Suite("RFC_9557.Validation - Suffix Value Format")
struct ValidationSuffixValueTests {
    @Test("Valid alphanumeric values")
    func validValues() throws {
        try RFC_9557.Validation.validateSuffixValue("hebrew")
        try RFC_9557.Validation.validateSuffixValue("iso8601")
        try RFC_9557.Validation.validateSuffixValue("ABC123")
        try RFC_9557.Validation.validateSuffixValue("a")
        try RFC_9557.Validation.validateSuffixValue("1")
    }

    @Test("Invalid: contains hyphens")
    func invalidHyphens() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixValue("foo-bar")
        }
    }

    @Test("Invalid: contains special characters")
    func invalidSpecialCharacters() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixValue("foo@bar")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixValue("foo.bar")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixValue("foo_bar")
        }
    }

    @Test("Invalid: empty value")
    func invalidEmpty() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateSuffixValue("")
        }
    }
}

@Suite("RFC_9557.Validation - Time Zone Name Format")
struct ValidationTimeZoneNameTests {
    @Test("Valid IANA time zone names")
    func validIANANames() throws {
        try RFC_9557.Validation.validateTimeZoneName("America/Los_Angeles")
        try RFC_9557.Validation.validateTimeZoneName("Europe/Paris")
        try RFC_9557.Validation.validateTimeZoneName("Asia/Tokyo")
        try RFC_9557.Validation.validateTimeZoneName("UTC")
        try RFC_9557.Validation.validateTimeZoneName("Etc/GMT+5")
    }

    @Test("Valid: names with dots and underscores")
    func validWithDotsUnderscores() throws {
        try RFC_9557.Validation.validateTimeZoneName("America/Indiana/Knox_IN.Starke")
        try RFC_9557.Validation.validateTimeZoneName("America/Argentina/ComodRivadavia")
    }

    @Test("Invalid: dot-only parts")
    func invalidDotParts() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateTimeZoneName(".")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateTimeZoneName("..")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateTimeZoneName("America/.")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateTimeZoneName("../Europe")
        }
    }

    @Test("Invalid: special characters")
    func invalidSpecialCharacters() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateTimeZoneName("America/Los@Angeles")
        }
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateTimeZoneName("Europe\\Paris")
        }
    }

    @Test("Invalid: empty name")
    func invalidEmpty() {
        #expect(throws: RFC_9557.Validation.ValidationError.self) {
            try RFC_9557.Validation.validateTimeZoneName("")
        }
    }
}

@Suite("RFC_9557.Validation - Registered Keys")
struct ValidationRegisteredKeysTests {
    @Test("u-ca is registered")
    func ucaIsRegistered() {
        #expect(RFC_9557.Validation.isRegisteredKey("u-ca"))
    }

    @Test("Unknown keys are not registered")
    func unknownNotRegistered() {
        #expect(!RFC_9557.Validation.isRegisteredKey("foo"))
        #expect(!RFC_9557.Validation.isRegisteredKey("bar"))
        #expect(!RFC_9557.Validation.isRegisteredKey("_experimental"))
    }
}
