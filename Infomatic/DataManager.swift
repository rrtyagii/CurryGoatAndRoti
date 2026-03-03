///Users/sukya/Documents/CurryGoatAndRoti/Infomatic/DataManager.swift
//  DataManager.swift
//  Infomatic
//
//  Created by Sukya Williams on 2/23/26.
//

import CoreData
import Foundation
import Combine

class DataManager: ObservableObject { //swallowing error; may need to revisit
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "InfomaticData")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { _, error in
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
    
    /// Returns true if all cards in the topic are read, and marks the topic as completed.
    @discardableResult
    func checkTopicComplete(for topic: Topic) -> Bool {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "topic == %@ AND isRead == false", topic)
        let unreadCount = (try? context.count(for: request)) ?? 0
        topic.isCompleted = unreadCount == 0
        save()
        return unreadCount == 0
    }
    
    /// Derived: a topic is considered started if it has at least one read card.
    func isTopicStarted(_ topic: Topic) -> Bool {
        let cards = topic.cards as? Set<Card> ?? []
        return cards.contains { $0.isRead }
    }
    
    // MARK: - Card
    
    func createCard(content: String, topic: Topic) -> Card {
        let card = Card(context: context)
        card.id = UUID()
        card.content = content
        card.generatedAt = Date()
        card.isBookmarked = false
        card.isRead = false
        card.topic = topic
        save()
        return card
    }
    
    func fetchCards(for topic: Topic) -> [Card] {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "topic == %@", topic)
        request.sortDescriptors = [NSSortDescriptor(key: "generatedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchBookmarkedCards() -> [Card] { // all cards
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmarked == true")
        request.sortDescriptors = [NSSortDescriptor(key: "generatedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchBookmarkedCardsByTopic(for topic: Topic) -> [Card] { //fetch bookmarked cards by topic
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmarked == true AND topic == %@", topic)
        request.sortDescriptors = [NSSortDescriptor(key: "generatedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func toggleBookmarked(_ card: Card) {
        card.isBookmarked.toggle()
        save()
    }
    
    func markCardAsRead(_ card: Card) {
        card.isRead = true
        save()
        if let topic = card.topic {
            checkTopicComplete(for: topic)
        }
    }
    
    func deleteCard(_ card: Card) {
        context.delete(card)
        save()
    }
    
    // MARK: - Conversation
    
    /// Creates a conversation linked to a specific card (e.g. double-tap on card).
    @discardableResult
    func createConversation(title: String, card: Card) -> Conversation {
        let conversation = Conversation(context: context)
        conversation.id = UUID()
        conversation.title = title
        conversation.createdAt = Date()
        conversation.card = card
        conversation.topicName = card.topic?.name  // snapshot topic name at creation
        save()
        return conversation
    }
    
    /// Creates a standalone conversation not linked to a card (e.g. topic-level Q&A).
    @discardableResult
    func createConversation(title: String, topicName: String) -> Conversation {
        let conversation = Conversation(context: context)
        conversation.id = UUID()
        conversation.title = title
        conversation.createdAt = Date()
        conversation.card = nil
        conversation.topicName = topicName
        save()
        return conversation
    }
    
    func fetchConversations() -> [Conversation] {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func deleteConversation(_ conversation: Conversation) {
        context.delete(conversation)
        save()
    }
    
    // MARK: - Message
    
    @discardableResult
    func addMessage(to conversation: Conversation, content: String, agent: String) -> Message {
        let message = Message(context: context)
        message.id = UUID()
        message.message = content
        message.agent = agent
        message.timestamp = Date()
        message.conversation = conversation
        save()
        return message
    }
    
    func fetchMessages(by conversationId: UUID) -> [Message] {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id == %@", conversationId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
}
