//
//  TopicLibrarySearchTests.swift
//  InfomaticTests
//
//  Created by Codex on 5/25/26.
//

import XCTest
@testable import Infomatic

final class TopicLibrarySearchTests: XCTestCase {
    func testSearchCombinesScoresAcrossMultipleExpandedTerms() {
        let combinedMatch = CardDetail(
            id: "combined-topic",
            tags: [],
            title: "Artificial Intelligence",
            preview: "",
            contentFile: "combined-topic.txt"
        )
        let singleMatch = CardDetail(
            id: "single-topic",
            tags: [],
            title: "Artificial Systems",
            preview: "",
            contentFile: "single-topic.txt"
        )

        let library = TopicLibrary(cards: [singleMatch, combinedMatch])
        let results = library.searchCards(matching: "art int")

        XCTAssertEqual(results.first?.card.id, combinedMatch.id)
        XCTAssertEqual(results.first?.score, 4)
        XCTAssertEqual(results.last?.card.id, singleMatch.id)
        XCTAssertEqual(results.last?.score, 2)
    }
}
