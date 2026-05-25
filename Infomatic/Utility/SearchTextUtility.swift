//
//  SearchTextUtility.swift
//  Infomatic
//
//  Created by Codex on 5/25/26.
//

import Foundation

enum SearchTextUtility {
    static let stopWords: Set<String> = [
        "a", "an", "the", "and", "or", "but", "if", "then", "else", "of", "in", "on", "at", "to", "for", "from", "by", "with", "without", "into", "onto", "over", "under", "between", "through", "during", "before", "after", "about", "as", "is", "are", "was", "were", "be", "been", "being", "it", "its", "this", "that", "these", "those", "there", "their", "they", "them", "he", "she", "his", "her", "we", "our", "you", "your", "i", "me", "my", "who", "which", "what", "when", "where", "why", "how", "do", "does", "did", "done", "can", "could", "would", "should", "may", "might", "not", "no", "yes", "also", "such", "other", "some", "more", "most", "many", "much", "one", "two", "three", "first", "second", "third"
    ]

    static let punctuationAndControlScalars = CharacterSet.punctuationCharacters
        .union(.newlines)
        .union(CharacterSet(charactersIn: "\t\r"))

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
}
