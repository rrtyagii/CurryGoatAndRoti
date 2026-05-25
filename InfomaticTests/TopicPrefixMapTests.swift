//
//  TopicPrefixMapTests.swift
//  InfomaticTests
//
//  Created by Codex on 5/25/26.
//

import XCTest
@testable import Infomatic

final class TopicPrefixMapTests: XCTestCase {
    func testExpandHandlesMultiplePrefixesAndKeepsUnknownTokens() {
        let prefixMap = TopicPrefixMap(with: [
            "article",
            "artificial",
            "intelligence",
            "internet",
            "swift"
        ])

        let expanded = Set(prefixMap.expand("art int unknown"))

        XCTAssertTrue(expanded.isSuperset(of: [
            "article",
            "artificial",
            "intelligence",
            "internet",
            "unknown"
        ]))
    }

    func testExpandReturnsEmptyForStopWordsOnlyQuery() {
        let prefixMap = TopicPrefixMap(with: ["artificial"])

        XCTAssertTrue(prefixMap.expand("the and or").isEmpty)
    }
}
