//
//  TopicInvertedIndexTests.swift
//  InfomaticTests
//
//  Created by Codex on 4/4/26.
//

import XCTest
@testable import Infomatic

final class TopicInvertedIndexTests: XCTestCase {
    func testNormalizeAndTokenizeMatchesPythonBehavior() {
        let tokens = TopicInvertedIndex.normalizeAndTokenize("The State-of-the-Art,\n in AI!")

        XCTAssertEqual(tokens, ["state", "art", "ai"])
    }

    func testBuildCapturesMetadataAcrossIndexedFields() {
        let swiftCard = CardDetail(
            id: "swift-ai",
            tags: ["machine learning", "swift"],
            title: "Swift AI",
            preview: "Learn Swift for AI builders.",
            contentFile: "swift-ai.txt"
        )

        let index = TopicInvertedIndex(cards: [swiftCard])
        let metadata = index.postings["swift"]?[swiftCard.id]

        XCTAssertEqual(metadata?.id, true)
        XCTAssertEqual(metadata?.title, true)
        XCTAssertEqual(metadata?.tags, true)
        XCTAssertEqual(metadata?.preview, true)
    }

    func testSearchRanksCardsByWeightedFieldMatches() {
        let topResult = CardDetail(
            id: "swift-ai",
            tags: ["machine learning", "swift"],
            title: "Swift AI",
            preview: "Learn Swift for AI builders.",
            contentFile: "swift-ai.txt"
        )

        let lowerResult = CardDetail(
            id: "ios-history",
            tags: ["mobile"],
            title: "Apple Platforms",
            preview: "Swift made modern iOS development much faster.",
            contentFile: "ios-history.txt"
        )

        let index = TopicInvertedIndex(cards: [topResult, lowerResult])
        let results = index.search("swift")

        XCTAssertEqual(results.first?.cardID, topResult.id)
        XCTAssertEqual(results.first?.score, 8)
        XCTAssertEqual(results.last?.cardID, lowerResult.id)
        XCTAssertEqual(results.last?.score, 1)
    }

    func testSearchReturnsEmptyForWhitespaceOrStopWordsOnlyQueries() {
        let card = CardDetail(
            id: "swift-ai",
            tags: ["swift"],
            title: "Swift AI",
            preview: "Learn Swift.",
            contentFile: "swift-ai.txt"
        )

        let index = TopicInvertedIndex(cards: [card])

        XCTAssertTrue(index.search("   ").isEmpty)
        XCTAssertTrue(index.search("the and or").isEmpty)
    }
}
