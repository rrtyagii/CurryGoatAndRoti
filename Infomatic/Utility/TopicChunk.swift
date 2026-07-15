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

struct TopicChunkScore: Identifiable {
    let id: UUID
    let score: Int
    let topicChunk: TopicChunk
}

class TopicChunker {
    private let card: CardDetail
    private let topicLibrary: TopicLibrary
    
    init(for card: CardDetail, with topicLibrary: TopicLibrary) {
        self.card = card
        self.topicLibrary = topicLibrary
    }
    
    func normalizeAndTokenize(_ text: String) -> [String] {
        SearchTextUtility.normalizeAndTokenize(text)
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
    
    func score(querySet: Set<String>, chunkSet: Set<String>) -> Int{
        let result = chunkSet.intersection(querySet)
        return result.count
    }
    
    /*
     
     score():
        takes a query set & chunk set
        we find the intersection words of query set and chunk set.
        score the chunk based on this - get the size
     
     
     getTopChunks():
         The behind this is tokenize & normalize the user-query;
         
         for each chunk in chunks
            give this chunk a score between your query & this chunk.
            store the chunks vs scores
         
         return top 3-5 chunks
     
     */
    
    func getTopChunks(userQuery: String) -> [TopicChunkScore]{
        let normalizedUserQuery = Set(normalizeAndTokenize(userQuery))
        
        
        let allScores = self.chunkContent().map { chunk -> TopicChunkScore in
            let chunkSet = Set(normalizeAndTokenize(chunk.text))
            let calculateScore = self.score(querySet: normalizedUserQuery, chunkSet: chunkSet)
            
            return TopicChunkScore(id: UUID(), score: calculateScore, topicChunk: chunk)
        }
        
        
        let topThree = allScores
            .sorted { $0.score > $1.score }
            .prefix(3)
        
        return Array(topThree)
    }
}

