///Users/sukya/Documents/CurryGoatAndRoti/Infomatic/DataManager.swift
//  DataManager.swift
//  Infomatic
//
//  Created by Sukya Williams on 2/23/26.
//

import CoreData
import Foundation
import Combine

class DataManager: ObservableObject {
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
  
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Topic
    func createTopic(name: String) -> Topic {
        let topic = Topic(context: context)
        topic.id = UUID()
        topic.name = name
        topic.createdAt = Date()
        topic.isCompleted = false
        topic.isStarted = false
        save()
        return topic
    }
    
    func fetchTopics() -> [Topic] {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    func deleteTopic(_ topic: Topic) {
        context.delete(topic)
        save()
    }
    
    //check all the cards based on a topic and if all their status' are read then mark topic as complete
    func checkTopicComplete(for topic: Topic) -> Bool {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "topic == %@ AND isRead == false", topic)
        request.fetchLimit = 1
        let count = (try? context.count(for: request)) ?? 0
        topic.isCompleted = count == 0
        save()
        return count == 0
    }
    
    // MARK: - Card
    func createCard(content: String, topic: Topic) -> Card {
        let card = Card(context: context)
        card.id = UUID()
        card.content = content
        card.generatedAt = Date()
        card.isBookmarked = false
        card.topic = topic
        card.isRead = false
        save()
        return card
    }
    
    func fetchCards(for topic: Topic) -> [Card] {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "topic == %@", topic)
        request.sortDescriptors = [NSSortDescriptor(key: "generatedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchSavedCards() -> [Card] {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmarked == true")
        request.sortDescriptors = [NSSortDescriptor(key: "generatedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func toggleBookmarked(_ card: Card) {
        card.isBookmarked.toggle()
        save()
    }
    
    func deleteCard(_ card: Card) {
        context.delete(card)
        save()
    }
    
    // update card isStarted value once a card has been read
    func markCardAsRead(_ card: Card) {
        card.isRead = true
        
        if let topic = card.topic, topic.isStarted == false {
            topic.isStarted = true
        }
        
        save()
    }
    
    // MARK: - ChatMessage
    
    // For double-tap on a card
    func saveChatMessage(question: String, answer: String, card: Card) -> ChatMessage {
        let message = ChatMessage(context: context)
        message.id = UUID()
        message.question = question
        message.askedAt = Date()
        message.card = card
        message.topicName = nil
        save()
        return message
    }
    
    // For topic-level Q&A (no specific card)
    func saveChatMessage(question: String, answer: String, topicName: String) -> ChatMessage {
        let message = ChatMessage(context: context)
        message.id = UUID()
        message.question = question
        message.askedAt = Date()
        message.card = nil        // means no card was submitted with this question
        message.topicName = topicName
        save()
        return message
    }
    
    func fetchChatHistory(for card: Card) -> [ChatMessage] {
        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "card == %@", card)
        request.sortDescriptors = [NSSortDescriptor(key: "askedAt", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchChatHistory(for topicName: String) -> [ChatMessage] {
        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "topicName == %@ AND card == nil", topicName)
        request.sortDescriptors = [NSSortDescriptor(key: "askedAt", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
}
