//
//  TopicInvertedIndex.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 4/4/26.
//

import Foundation

struct TopicSearchResult: Equatable { // protocol to compare two Objects of same type.
    let cardID: String
    let score: Int
    // we didn't explicitly write a equal function so swift is doing it for us behiind the scenes. A TopicSearchResult will be "equal" to another if and only if when both cardId and score are same.
}

struct TopicInvertedIndex {
    enum Field {
        case id
        case title
        case tags
        case preview
    }

    struct Weights: Equatable {
        // two "Weights" object are same if and only if when all the properties and their properties will have same values.
        let tags: Int
        let title: Int
        let id: Int
        let preview: Int

        static let `default` = Self(tags: 3, title: 2, id: 2, preview: 1) // capital s (S) referes to the type itself.
    }

    struct Metadata: Equatable {
        var id = false
        var title = false
        var tags = false
        var preview = false

        mutating func mark(_ field: Field) {
            switch field {
            case .id:
                id = true
            case .title:
                title = true
            case .tags:
                tags = true
            case .preview:
                preview = true
            }
        }

        func score(using weights: Weights) -> Int {
            var total = 0

            if title {
                total += weights.title
            }
            if tags {
                total += weights.tags
            }
            if preview {
                total += weights.preview
            }
            if id {
                total += weights.id
            }

            return total
        }
    }

    static let stopWords: Set<String> = [
        "a", "an", "the", "and", "or", "but", "if", "then", "else", "of", "in", "on", "at", "to", "for", "from", "by", "with", "without", "into", "onto", "over", "under", "between", "through", "during", "before", "after", "about", "as", "is", "are", "was", "were", "be", "been", "being", "it", "its", "this", "that", "these", "those", "there", "their", "they", "them", "he", "she", "his", "her", "we", "our", "you", "your", "i", "me", "my", "who", "which", "what", "when", "where", "why", "how", "do", "does", "did", "done", "can", "could", "would", "should", "may", "might", "not", "no", "yes", "also", "such", "other", "some", "more", "most", "many", "much", "one", "two", "three", "first", "second", "third"
    ]

    private static let punctuationAndControlScalars = CharacterSet.punctuationCharacters
        .union(.newlines)
        .union(CharacterSet(charactersIn: "\t\r")) // immutable static constant of punctuation characters, newlines, tabs

    private(set) var postings: [String: [String: Metadata]] = [:]// Nested dictionary
    // [ keyword 1: [
    //              document A: Metadata (),
    //              document B: Metadata()
    //            ],
    // ]
    
    let weights: Weights

    init(cards: [CardDetail] = [], weights: Weights = .default) {
        self.weights = weights
        rebuild(using: cards)
    }
    
    static func normalizeAndTokenize(_ text: String) -> [String] {
        let hyphenNormalized = text.replacingOccurrences(of: "-", with: " ").lowercased()
        let cleaned = String(
            hyphenNormalized.unicodeScalars.filter { !punctuationAndControlScalars.contains($0) }
        )

        return cleaned
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .filter { !stopWords.contains($0) }
    }
    
    // posting is a mutable Nested dictionary
    // [ keyword 1: [
    //              document A: Metadata (),
    //              document B: Metadata()
    //            ],
    //   keyword 2: [
    //              document A: Metadata (),
    //              document B: Metadata()
    //            ],
    //   .....
    // ]

    private mutating func populate(tokens: [String], cardID: String, field: Field) {
        for token in tokens {
            var posting = postings[token] ?? [:] // fetch the document list for a 'token' otherwise an empty Dictionary. We are making a unique copy of postings[token] and putting it withiin posting here. Instead of "chasing" a reference.
            var metadata = posting[cardID] ?? Metadata() // fetch the metadata of a specific card otherwise default Metadata.
            metadata.mark(field) // mark the specific field as "occuring" or "true"
            posting[cardID] = metadata // update the metadata of the document list for the token
            postings[token] = posting // the update the document list for the token with the new document list and metadata.
        }
    }
    

    //  We have this mutating function rebuild(). This way we are telling swift compiler that we are going to change the values. We are normalizing and tokenizing. Replace hypen with "spaces". Clean out punctuations. split on white spaces, filter out stop words. Then we call Populate() where we fetch the document list for a 'token' otherwise an empty Dictionary. Then we fetch the metadata of a specific card otherwise default Metadata and mark the specific field as "occuring" or "true". With that being done, we update the metadata of the document list for the token. Finally, we update the document list for the token with the new document list and metadata. We do this for id, title, preview, tokens, and tags.
    
    mutating func rebuild(using cards: [CardDetail]) {
        postings.removeAll(keepingCapacity: true)

        for card in cards {
            if weights.id > 0 {
                populate(tokens: Self.normalizeAndTokenize(card.id), cardID: card.id, field: .id)
            }

            populate(tokens: Self.normalizeAndTokenize(card.title), cardID: card.id, field: .title)
            populate(tokens: Self.normalizeAndTokenize(card.preview), cardID: card.id, field: .preview)

            for tag in card.tags {
                populate(tokens: Self.normalizeAndTokenize(tag), cardID: card.id, field: .tags)
            }
        }
    }

    func search(_ query: String) -> [TopicSearchResult] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { // making sure query is not blank or empty
            return []
        }

        let queryTokens = Self.normalizeAndTokenize(query)
        guard !queryTokens.isEmpty else { // making sure query tokens are not blank or empty
            return []
        }

        var scoresByCardID: [String: Int] = [:]

        for token in queryTokens {
            guard let posting = postings[token] else {
                continue
            }

            for (cardID, metadata) in posting {
                scoresByCardID[cardID, default: 0] += metadata.score(using: weights)
            }
        }

        return scoresByCardID
            .map { TopicSearchResult(cardID: $0.key, score: $0.value) }
            .sorted {
                if $0.score == $1.score {
                    return $0.cardID < $1.cardID
                }
                return $0.score > $1.score
            }
    }
}
