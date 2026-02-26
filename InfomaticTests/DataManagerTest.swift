//
//  DataManagerTest.swift
//  Infomatic
//
//  Created by Sukya Williams on 2/25/26.
//

import XCTest
import CoreData
@testable import Infomatic

final class DataManagerTests: XCTestCase {
    
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager(inMemory: true)
    }
    
    
    override func tearDown() {
        dataManager = nil
        super.tearDown()
    }
    
    // MARK: - Topic Tests
    
    func test_createTopic_savesCorrectly() {
        let topic = dataManager.createTopic(name: "Quantum Physics")
        
        XCTAssertEqual(topic.name, "Quantum Physics")
        XCTAssertNotNil(topic.id)
        XCTAssertNotNil(topic.createdAt)
    }
    
    func test_fetchTopics_returnsAllTopics() {
        let topic1 = dataManager.createTopic(name: "Physics")
        let topic2 = dataManager.createTopic(name: "Math")
        let topic3 = dataManager.createTopic(name: "History")
        
        let topics = dataManager.fetchTopics()
        
        XCTAssertEqual(topics.count, 3)
        XCTAssert(Set(topics.map(\.name)) == [topic1.name, topic2.name, topic3.name])
    }
    
    func test_deleteTopic_removesFromDatabase() {
        let topic = dataManager.createTopic(name: "Physics")
        dataManager.deleteTopic(topic)
        
        let topics = dataManager.fetchTopics()
        
        XCTAssertEqual(topics.count, 0)
    }
    
    // MARK: - Card Tests
    
    func test_createCard_savesCorrectly() {
        let topic = dataManager.createTopic(name: "Physics")
        let card = dataManager.createCard(content: "Light travels at 299,792 km/s", topic: topic)
        
        XCTAssertEqual(card.content, "Light travels at 299,792 km/s")
        XCTAssertEqual(card.topic, topic)
        XCTAssertFalse(card.isBookmarked)
    }
    
    func test_fetchCards_returnsCardsForTopic() {
        let physics = dataManager.createTopic(name: "Physics")
        let math = dataManager.createTopic(name: "Math")
        
        let card1 = dataManager.createCard(content: "Card 1", topic: physics)
        let card2 = dataManager.createCard(content: "Card 2", topic: physics)
        _ = dataManager.createCard(content: "Card 3", topic: math)
        
        let physicsCards = dataManager.fetchCards(for: physics)
        
        XCTAssertEqual(physicsCards.count, 2)
        XCTAssert(physicsCards.contains(card1))
        XCTAssert(physicsCards.contains(card2))
    }
    
    func test_toggleBookmarked_flipsValue() {
        let topic = dataManager.createTopic(name: "Physics")
        let card = dataManager.createCard(content: "Test card", topic: topic)
        
        XCTAssertFalse(card.isBookmarked)
        
        dataManager.toggleBookmarked(card)
        XCTAssertTrue(card.isBookmarked)
        
        dataManager.toggleBookmarked(card)
        XCTAssertFalse(card.isBookmarked)
    }
    
    func test_deleteTopic_cascadeDeletesCards() {
        let topic = dataManager.createTopic(name: "Physics")
        _ = dataManager.createCard(content: "Card 1", topic: topic)
        _ = dataManager.createCard(content: "Card 2", topic: topic)
        
        dataManager.deleteTopic(topic)
        
        let cards = dataManager.fetchCards(for: topic)
        XCTAssertEqual(cards.count, 0)
    }
    
    // MARK: - isRead / isStarted / isCompleted Tests
    
    func test_markCardAsRead_setsTopicIsStarted() {
        let topic = dataManager.createTopic(name: "Physics")
        let card = dataManager.createCard(content: "Test card", topic: topic)
        
        XCTAssertFalse(topic.isStarted)
        
        dataManager.markCardAsRead(card)
        
        XCTAssertTrue(card.isRead)
        XCTAssertTrue(topic.isStarted)
    }
    
    func test_checkTopicComplete_trueWhenAllCardsRead() {
        let topic = dataManager.createTopic(name: "Physics")
        let card1 = dataManager.createCard(content: "Card 1", topic: topic)
        let card2 = dataManager.createCard(content: "Card 2", topic: topic)
        
        dataManager.markCardAsRead(card1)
        dataManager.markCardAsRead(card2)
        
        let isComplete = dataManager.checkTopicComplete(for: topic)
        
        XCTAssertTrue(isComplete)
        XCTAssertTrue(topic.isCompleted)
    }
    
    func test_checkTopicComplete_falseWhenUnreadCardsExist() {
        let topic = dataManager.createTopic(name: "Physics")
        _ = dataManager.createCard(content: "Card 1", topic: topic)
        
        let isComplete = dataManager.checkTopicComplete(for: topic)
        
        XCTAssertFalse(isComplete)
    }
    
    // MARK: - ChatMessage Tests
    
    func test_saveChatMessage_linkedToCard() {
        let topic = dataManager.createTopic(name: "Physics")
        let card = dataManager.createCard(content: "Test card", topic: topic)
        
        let message = dataManager.saveChatMessage(question: "Why?", answer: "Because physics", card: card)
        
        XCTAssertEqual(message.question, "Why?")
        XCTAssertEqual(message.card, card)
        XCTAssertNil(message.topicName)
    }
    
    func test_saveChatMessage_topicLevel() {
        let message = dataManager.saveChatMessage(question: "What is physics?", answer: "The study of matter", topicName: "Physics")
        
        XCTAssertEqual(message.topicName, "Physics")
        XCTAssertNil(message.card)
    }
    
    func test_fetchChatHistory_forCard() {
        let topic = dataManager.createTopic(name: "Physics")
        let card = dataManager.createCard(content: "Test card", topic: topic)
        
        let message1 = dataManager.saveChatMessage(question: "Q1", answer: "A1", card: card)
        let message2 = dataManager.saveChatMessage(question: "Q2", answer: "A2", card: card)
        
        let history = dataManager.fetchChatHistory(for: card)
        
        XCTAssertEqual(history.count, 2)
        XCTAssert(history.contains(message1))
        XCTAssert(history.contains(message2))
    }
}
