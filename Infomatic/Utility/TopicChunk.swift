//
//  TopicChunk.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 6/2/26.
//

import Foundation
import SwiftUI

struct TopicChunk: Identifiable {
    let id: UUID
    let topicId: String
    let text: String
    let order: Int
}

class TopicChunker {
    @EnvironmentObject var topicLibrary: TopicLibrary
    private let card: CardDetail
    
    init(with card: CardDetail) {
        self.card = card
    }
    
    func chunkContent() -> [TopicChunk] {
        var result: [TopicChunk] = []
        
        let text = self.topicLibrary.content(for: card)
        let textChunks: [ String ] = text.components(separatedBy: "\n\n").filter({ content in
            !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        })
        
        for (index, value) in textChunks.enumerated() {
            let topicChunk = TopicChunk(id: UUID(), topicId: card.id, text: value, order: index)
            result.append(topicChunk)
        }
        
        return result
    }
}
