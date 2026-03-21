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
    @Published private(set) var cards: [CardDetail] = []
    
    private var contentCache: [String: String] = [:]
    
    init(){
        loadIndexIfNeeded()
    }
    
    func loadIndexIfNeeded(){
        guard cards.isEmpty else { return }
        cards = TopicLoader.loadIndex()
    }
    
    func content(for card: CardDetail) -> String{
        if let cached = contentCache[card.contentFile]{
            return cached
        }
        
        let loaded = TopicLoader.loadTopicContent(from: card.contentFile)
        contentCache[card.contentFile] = loaded
        return loaded
    }
    
    func card(for id: String) -> CardDetail? {
        cards.first { $0.id == id }
    }
}
