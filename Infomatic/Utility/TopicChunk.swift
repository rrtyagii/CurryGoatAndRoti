//
//  TopicChunk.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 6/2/26.
//

import Foundation
import SwiftUI


enum AppConfig {
    static let allowsDebugMessage: Bool = {
    #if DEBUG
            return true
    #else
            return false
    #endif
    }()
}

struct TopicChunk: Identifiable {
    let id: UUID
    let topicId: String
    let text: String
    let order: Int
    let size: Int?

    init(id: UUID, topicId: String, text: String, order: Int, size: Int? = nil) {
        self.id = id
        self.topicId = topicId
        self.text = text
        self.order = order
        self.size = size
    }
}


struct TopicChunkScore: Identifiable {
    let id: UUID
    let score: Int
    let topicChunk: TopicChunk
}

struct TopicChunkResult: Identifiable{
    let id: UUID
    let chunks: [TopicChunkScore]
    let debugMessage: String?
    
    init(id: UUID, chunks: [TopicChunkScore], debugMessage: String?=nil) {
        self.id = id
        self.chunks = chunks
        self.debugMessage=debugMessage
    }
}

class TopicChunker {
    private let card: CardDetail
    private let topicLibrary: TopicLibrary
    //let isDebugging = ProcessInfo.processInfo.environment["IS_DEBUGGING"] == "true"
    
    init(for card: CardDetail, with topicLibrary: TopicLibrary) {
        self.card = card
        self.topicLibrary = topicLibrary
    }
    
    func normalizeAndTokenize(_ text: String) -> [String] {
        SearchTextUtility.normalizeAndTokenize(text)
    }
    
    func chunkContent() -> [TopicChunk] {
        var result: [TopicChunk] = []
        var topicChunk: TopicChunk
        
        let text = self.topicLibrary.content(for: card)
        let textChunks: [ String ] = text.components(separatedBy: "\n\n").filter({ content in
            !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        })
        
        for (index, value) in textChunks.enumerated() {
            if AppConfig.allowsDebugMessage{
                topicChunk = TopicChunk(id: UUID(), topicId: card.id, text: value, order: index, size: value.count)
            } else{
                topicChunk = TopicChunk(id: UUID(), topicId: card.id, text: value, order: index)
            }
            
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
    
    func getTopChunks(userQuery: String) -> TopicChunkResult {
        let normalizedUserQuery = Set(normalizeAndTokenize(userQuery))
        
        
        let allScores = self.chunkContent().map { chunk -> TopicChunkScore in
            let chunkSet = Set(normalizeAndTokenize(chunk.text))
            let calculateScore = self.score(querySet: normalizedUserQuery, chunkSet: chunkSet)
            return TopicChunkScore(id: UUID(), score: calculateScore, topicChunk: chunk)
        }
        
        
        let topThree = allScores
            .sorted { $0.score > $1.score }
            .prefix(3)
        
        let result = Array(topThree)
        
        let debugMessage: String?
        
        if AppConfig.allowsDebugMessage{
            let totalCharacters = result.reduce(0){total, chunkScore in
                total+chunkScore.topicChunk.text.count
            }
            
            //let scoreBreakdown = all
            
            let chunkOrders = result
                .map {String($0.topicChunk.order)}
                .joined(separator: ", ")
            
            print("characters: \(totalCharacters), order: \(chunkOrders)")
            debugMessage = "characters: \(totalCharacters), order: \(chunkOrders)"
        } else{
            debugMessage = nil
        }
        
        return TopicChunkResult(
            id: UUID(),
            chunks: result,
            debugMessage: debugMessage
        )
    }
}
