//
//  TopicLoader.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 3/5/26.
//

import Foundation


enum TopicLoader{
    static func loadIndex() -> [CardDetail] {
        guard let url = Bundle.main.url(forResource: "topic_index", withExtension: "json") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([CardDetail].self, from: data)
        } catch {
            print("Index decode error: \(error)")
            return []
        }
    }
    
    static func loadTopicContent(from path: String) -> String {
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileName = URL(fileURLWithPath: trimmedPath).lastPathComponent

        // Your bundle currently flattens resources, so both lookups are needed:
        // 1) "topics/foo.txt" (if folder is preserved)
        // 2) "foo.txt" (current flattened bundle layout)
        let url = Bundle.main.url(forResource: trimmedPath, withExtension: nil)
            ?? Bundle.main.url(forResource: fileName, withExtension: nil)

        guard let url else {
            print("TopicLoader: Content not found for path '\(path)'")
            return "Content not found."
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("TopicLoader: Failed to load '\(fileName)': \(error)")
            return "Failed to load content."
        }
    }

}
