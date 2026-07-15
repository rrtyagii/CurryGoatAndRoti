//
//  TopicLibrary.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 3/13/26.
//

import SwiftUI
import Foundation
import Combine

final class TopicLibrary: ObservableObject {
    // ObservableObject is a protocol for class based data model that is useful for changing UI state. It trigger UI state change when one of the properties that is tagged by the "Published" keyword is changed.
    
    
    struct SearchResult: Identifiable { // making searchResult to conform to Identifiable protocol; this means that each "Search Result" can be identified easily by swift based on the id property
        let card: CardDetail
        let score: Int
        var id: String {
            card.id
        }
    }

    @Published private(set) var cards: [CardDetail] = [] // array of cards of type CardDetail. Public Read; private write.
    
    private var contentCache: [String: String] = [:]
    private var topicInvertedIndex = TopicInvertedIndex()
    private var prefixMap: TopicPrefixMap?
    
    init() {
        loadIndexIfNeeded()
    }

    init(cards: [CardDetail]) {
        self.cards = cards
        topicInvertedIndex.rebuild(using: cards)
        prefixMap = TopicPrefixMap(with: topicInvertedIndex.getVocabulary())
    }
    
    func loadIndexIfNeeded() {
        guard cards.isEmpty else { return }
        cards = TopicLoader.loadIndex()
        topicInvertedIndex.rebuild(using: cards)
        prefixMap = TopicPrefixMap(with: topicInvertedIndex.getVocabulary())
    }
    
    func content(for card: CardDetail) -> String {
        if let cached = contentCache[card.contentFile] {
            return cached
        }
        
        let loaded = TopicLoader.loadTopicContent(from: card.contentFile)
        contentCache[card.contentFile] = loaded
        return loaded
    }
    
    func card(for id: String) -> CardDetail? {
        cards.first { $0.id == id }
    }

    func searchCards(matching query: String) -> [SearchResult] {
        loadIndexIfNeeded()

        guard !cards.isEmpty else {
            return []
        }

        let cardsByID = Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) })
        let expandedTerms = prefixMap?.expand(query) ?? [query]

        var scoresByCardID: [String: Int] = [:]

        for term in expandedTerms {
            for result in topicInvertedIndex.search(term) {
                scoresByCardID[result.cardID, default: 0] += result.score
            }
        }

        return scoresByCardID
            .compactMap { cardID, score in
                guard let card = cardsByID[cardID] else {
                    return nil
                }

                return SearchResult(card: card, score: score)
            }
            .sorted {
                if $0.score == $1.score {
                    return $0.card.id < $1.card.id
                }

                return $0.score > $1.score
            }
    }
}
