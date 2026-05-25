//
//  TopicPrefixMap.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 5/14/26.
//

import Foundation

struct PrefixMapCache: Codable {
    let vocabularyFingerprint: String
    let entries: [String: Set<String>]
}

struct TopicPrefixMap {
    private let MINIMUM_LENGTH = 2
    private let MAXIMUM_LENGTH = 5

    static let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let cacheDirectoryURL = TopicPrefixMap.documentDirectoryURL.appendingPathComponent("Infomatic/PrefixMapCache")

    private var prefixMap: [String: Set<String>]

    init(with vocabulary: [String] = []) {
        self.prefixMap = [:]
        readJsonData(vocabulary: vocabulary)
    }

    private func vocabularyFingerprint(for vocabulary: [String]) -> String {
        return vocabulary.sorted().joined(separator: "|")
    }

    private func writeJsonData(to filename: String, with cache: PrefixMapCache) {
        do {
            try FileManager.default.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
            var fileNameUrl = cacheDirectoryURL.appendingPathComponent(filename)

            if fileNameUrl.pathExtension != "json" {
                fileNameUrl = fileNameUrl.appendingPathExtension("json")
            }

            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(cache)

            try jsonData.write(to: fileNameUrl)

        } catch {
            print("Error while writingJsonData to \(filename): \(error)")
        }
    }

    private mutating func readJsonData(vocabulary: [String]) {
        guard !vocabulary.isEmpty else {
            self.prefixMap = [:]
            return
        }

        let signature = vocabularyFingerprint(for: vocabulary)

        let filename: URL = cacheDirectoryURL.appendingPathComponent("prefix_map.json")

        func rebuildAndWriteCache() {
            self.prefixMap = computePrefix(from: vocabulary)
            let cache = PrefixMapCache(
                vocabularyFingerprint: signature,
                entries: self.prefixMap
            )
            writeJsonData(to: "prefix_map.json", with: cache)
        }

        do {
            let jsonData = try Data(contentsOf: filename)
            let jsonDecoder = JSONDecoder()
            let readingData = try jsonDecoder.decode(PrefixMapCache.self, from: jsonData)

            let isDataValid = readingData.vocabularyFingerprint == signature && !readingData.entries.isEmpty

            if isDataValid {
                self.prefixMap = readingData.entries
            } else {
                rebuildAndWriteCache()
            }

        } catch {
            print("Error while readingJsonData from \(filename): \(error)")
            rebuildAndWriteCache()
        }
    }

    private func computePrefix(from vocabulary: [String]) -> [String: Set<String>] {
        var prefixMap: [String: Set<String>] = [:]

        for word in vocabulary {
            for position in MINIMUM_LENGTH...MAXIMUM_LENGTH {
                if position > word.count {
                    continue
                }

                let currentPrefix = String(word.prefix(position)).lowercased()
                prefixMap[currentPrefix, default: []].insert(word)
            }
        }

        return prefixMap
    }

    func expand(_ query: String) -> [String] {
        let tokens = SearchTextUtility.normalizeAndTokenize(query)

        guard !tokens.isEmpty else {
            return []
        }

        var result: [String] = []

        for token in tokens {
            if let words = prefixMap[token] {
                result.append(contentsOf: words)
            } else {
                result.append(token)
            }
        }

        return result
    }
}
