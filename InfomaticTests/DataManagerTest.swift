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

    // MARK: - Topic

    func test_createTopic_setsAllFields() {
        let topic = dataManager.createTopic(name: "Swift Basics")

        XCTAssertNotNil(topic.id)
        XCTAssertEqual(topic.name, "Swift Basics")
        XCTAssertNotNil(topic.createdAt)
        XCTAssertFalse(topic.isCompleted)
    }

    func test_fetchTopics_returnsAllCreatedTopics() {
        let _ = dataManager.createTopic(name: "Topic A")
        let _ = dataManager.createTopic(name: "Topic B")

        XCTAssertEqual(dataManager.fetchTopics().count, 2)
    }

    func test_fetchTopics_sortedOldestFirst() {
        let _ = dataManager.createTopic(name: "First")
        Thread.sleep(forTimeInterval: 0.01) //prevents creation timestamps from being identical
        let _ = dataManager.createTopic(name: "Second")

        let topics = dataManager.fetchTopics()
        XCTAssertEqual(topics.first?.name, "First")
        XCTAssertEqual(topics.last?.name, "Second")
    }

    func test_deleteTopic_removesTopic() {
        let topic = dataManager.createTopic(name: "To Delete")
        dataManager.deleteTopic(topic)

        XCTAssertEqual(dataManager.fetchTopics().count, 0)
    }

    func test_deleteTopic_cascadeDeletesCards() { // verifies that deleting a topic also deletes its associated cards
        let topic = dataManager.createTopic(name: "Topic")
        let _ = dataManager.createCard(content: "Card 1", topic: topic)
        let _ = dataManager.createCard(content: "Card 2", topic: topic)
        let _ = dataManager.deleteTopic(topic)

        let request: NSFetchRequest<Card> = Card.fetchRequest()
        let remaining = (try? dataManager.context.fetch(request)) ?? []
        XCTAssertEqual(remaining.count, 0)
    }

    func test_checkTopicComplete_trueWhenAllCardsRead() {
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Card", topic: topic)
        dataManager.markCardAsRead(card)

        XCTAssertTrue(topic.isCompleted)
    }

    func test_checkTopicComplete_falseWhenUnreadCardsExist() {
        let topic = dataManager.createTopic(name: "Topic")
        let _ = dataManager.createCard(content: "Unread", topic: topic)

        XCTAssertFalse(dataManager.checkTopicComplete(for: topic))
        XCTAssertFalse(topic.isCompleted)
    }

    func test_checkTopicComplete_falseWhenMixedReadState() {
        let topic = dataManager.createTopic(name: "Topic")
        let card1 = dataManager.createCard(content: "Card 1", topic: topic)
        let _ = dataManager.createCard(content: "Card 2", topic: topic)
        let _ = dataManager.markCardAsRead(card1)

        XCTAssertFalse(topic.isCompleted)
    }

    func test_isTopicStarted_falseWithNoCards() {
        let topic = dataManager.createTopic(name: "Empty")

        XCTAssertFalse(dataManager.isTopicStarted(topic))
    }

    func test_isTopicStarted_falseWhenNoCardsRead() {
        let topic = dataManager.createTopic(name: "Topic")
        let _ = dataManager.createCard(content: "Card", topic: topic)

        XCTAssertFalse(dataManager.isTopicStarted(topic))
    }

    func test_isTopicStarted_trueWhenAtLeastOneCardRead() {
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Card", topic: topic)
        dataManager.markCardAsRead(card)

        XCTAssertTrue(dataManager.isTopicStarted(topic))
    }

    // MARK: - Card

    func test_createCard_setsAllFields() {
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Hello", topic: topic)

        XCTAssertNotNil(card.id)
        XCTAssertEqual(card.content, "Hello")
        XCTAssertNotNil(card.generatedAt)
        XCTAssertFalse(card.isBookmarked)
        XCTAssertFalse(card.isRead)
        XCTAssertEqual(card.topic, topic)
    }

    func test_fetchCards_scopedToTopic() {
        let topicA = dataManager.createTopic(name: "A")
        let topicB = dataManager.createTopic(name: "B")
        let _ = dataManager.createCard(content: "Card A", topic: topicA)
        let _ = dataManager.createCard(content: "Card B", topic: topicB)

        XCTAssertEqual(dataManager.fetchCards(for: topicA).count, 1)
        XCTAssertEqual(dataManager.fetchCards(for: topicA).first?.content, "Card A")
    }

    func test_fetchCards_sortedNewestFirst() {
        let topic = dataManager.createTopic(name: "Topic")
        let _ = dataManager.createCard(content: "First", topic: topic)
        Thread.sleep(forTimeInterval: 0.01)
        let _ = dataManager.createCard(content: "Second", topic: topic)

        let cards = dataManager.fetchCards(for: topic)
        XCTAssertEqual(cards.first?.content, "Second")
        XCTAssertEqual(cards.last?.content, "First")
    }

    func test_toggleBookmarked_togglesState() {
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Card", topic: topic)

        dataManager.toggleBookmarked(card)
        XCTAssertTrue(card.isBookmarked)

        dataManager.toggleBookmarked(card)
        XCTAssertFalse(card.isBookmarked)
    }

    func test_fetchBookmarkedCards_returnsAllBookmarkedAcrossTopics() {
        let topicA = dataManager.createTopic(name: "A")
        let topicB = dataManager.createTopic(name: "B")
        let card1 = dataManager.createCard(content: "Card 1", topic: topicA)
        let card2 = dataManager.createCard(content: "Card 2", topic: topicB)
        let _ = dataManager.createCard(content: "Card 3", topic: topicA) // not bookmarked

        dataManager.toggleBookmarked(card1)
        dataManager.toggleBookmarked(card2)

        XCTAssertEqual(dataManager.fetchBookmarkedCards().count, 2)
    }

    func test_fetchBookmarkedCardsByTopic_scopedToTopic() {
        let topicA = dataManager.createTopic(name: "A")
        let topicB = dataManager.createTopic(name: "B")
        let cardA = dataManager.createCard(content: "Card A", topic: topicA)
        let cardB = dataManager.createCard(content: "Card B", topic: topicB)

        dataManager.toggleBookmarked(cardA)
        dataManager.toggleBookmarked(cardB)

        let results = dataManager.fetchBookmarkedCardsByTopic(for: topicA)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.content, "Card A")
    }

    func test_fetchBookmarkedCardsByTopic_excludesUnbookmarked() {
        let topic = dataManager.createTopic(name: "Topic")
        let _ = dataManager.createCard(content: "Not Bookmarked", topic: topic)

        XCTAssertEqual(dataManager.fetchBookmarkedCardsByTopic(for: topic).count, 0)
    }

    func test_markCardAsRead_setsIsRead() {
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Card", topic: topic)
        dataManager.markCardAsRead(card)

        XCTAssertTrue(card.isRead)
    }

    func test_markCardAsRead_completesTopicWhenAllRead() {
        let topic = dataManager.createTopic(name: "Topic")
        let card1 = dataManager.createCard(content: "Card 1", topic: topic)
        let card2 = dataManager.createCard(content: "Card 2", topic: topic)

        dataManager.markCardAsRead(card1)
        XCTAssertFalse(topic.isCompleted)

        dataManager.markCardAsRead(card2)
        XCTAssertTrue(topic.isCompleted)
    }

    func test_deleteCard_removesCard() {
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Card", topic: topic)
        dataManager.deleteCard(card)

        XCTAssertEqual(dataManager.fetchCards(for: topic).count, 0)
    }

    func test_deleteCard_cascadeDeletesConversations() { // design choice to prevent orphaned conversations without a card - model won't have context
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Card", topic: topic)
        dataManager.createConversation(title: "Convo", card: card)
        dataManager.deleteCard(card)

        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        let remaining = (try? dataManager.context.fetch(request)) ?? []
        XCTAssertEqual(remaining.count, 0)
    }

    // MARK: - Conversation

    func test_createConversation_linkedToCard_setsAllFields() {
        let topic = dataManager.createTopic(name: "Swift")
        let card = dataManager.createCard(content: "Card", topic: topic)
        let convo = dataManager.createConversation(title: "My Convo", card: card)

        XCTAssertNotNil(convo.id)
        XCTAssertEqual(convo.title, "My Convo")
        XCTAssertNotNil(convo.createdAt)
        XCTAssertEqual(convo.card, card)
        XCTAssertEqual(convo.topicName, "Swift") // snapshot from topic name
    }

    func test_createConversation_standalone_setsAllFields() {
        let convo = dataManager.createConversation(title: "General Q&A", topicName: "Swift")

        XCTAssertNotNil(convo.id)
        XCTAssertEqual(convo.title, "General Q&A")
        XCTAssertEqual(convo.topicName, "Swift")
        XCTAssertNil(convo.card)
    }

    func test_fetchConversations_sortedNewestFirst() {
        dataManager.createConversation(title: "First", topicName: "Swift")
        Thread.sleep(forTimeInterval: 0.01)
        dataManager.createConversation(title: "Second", topicName: "Swift")

        let convos = dataManager.fetchConversations()
        XCTAssertEqual(convos.first?.title, "Second")
        XCTAssertEqual(convos.last?.title, "First")
    }

    func test_fetchConversations_returnsAll() {
        dataManager.createConversation(title: "Convo 1", topicName: "Swift")
        let topic = dataManager.createTopic(name: "Topic")
        let card = dataManager.createCard(content: "Card", topic: topic)
        dataManager.createConversation(title: "Convo 2", card: card)

        XCTAssertEqual(dataManager.fetchConversations().count, 2)
    }

    func test_deleteConversation_removesIt() {
        let convo = dataManager.createConversation(title: "Convo", topicName: "Swift")
        dataManager.deleteConversation(convo)

        XCTAssertEqual(dataManager.fetchConversations().count, 0)
    }

    func test_deleteConversation_cascadeDeletesMessages() {
        let convo = dataManager.createConversation(title: "Convo", topicName: "Swift")
        dataManager.addMessage(to: convo, content: "Hello", agent: "user")
        dataManager.deleteConversation(convo)

        let request: NSFetchRequest<Message> = Message.fetchRequest()
        let remaining = (try? dataManager.context.fetch(request)) ?? []
        XCTAssertEqual(remaining.count, 0)
    }

    // MARK: - Message

    func test_addMessage_setsAllFields() {
        let convo = dataManager.createConversation(title: "Convo", topicName: "Swift")
        let message = dataManager.addMessage(to: convo, content: "Hello", agent: "user")

        XCTAssertNotNil(message.id)
        XCTAssertEqual(message.message, "Hello")
        XCTAssertEqual(message.agent, "user")
        XCTAssertNotNil(message.timestamp)
        XCTAssertEqual(message.conversation, convo)
    }

    func test_fetchMessages_byConversationId_sortedByTimestamp() {
        let convo = dataManager.createConversation(title: "Convo", topicName: "Swift")
        dataManager.addMessage(to: convo, content: "First", agent: "user")
        Thread.sleep(forTimeInterval: 0.01)
        dataManager.addMessage(to: convo, content: "Second", agent: "assistant")

        let messages = dataManager.fetchMessages(by: convo.id!)
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages.first?.message, "First")
        XCTAssertEqual(messages.last?.message, "Second")
    }

    func test_fetchMessages_byConversationId_scopedToConversation() {
        let convoA = dataManager.createConversation(title: "A", topicName: "Swift")
        let convoB = dataManager.createConversation(title: "B", topicName: "Swift")
        dataManager.addMessage(to: convoA, content: "Msg A", agent: "user")
        dataManager.addMessage(to: convoB, content: "Msg B", agent: "user")

        XCTAssertEqual(dataManager.fetchMessages(by: convoA.id!).count, 1)
        XCTAssertEqual(dataManager.fetchMessages(by: convoB.id!).count, 1)
    }

    func test_fetchMessages_byConversationId_returnsEmptyForUnknownId() {
        XCTAssertEqual(dataManager.fetchMessages(by: UUID()).count, 0)
    }

    func test_fetchMessages_agentRolesStoredCorrectly() {
        let convo = dataManager.createConversation(title: "Convo", topicName: "Swift")
        dataManager.addMessage(to: convo, content: "Question", agent: "user")
        dataManager.addMessage(to: convo, content: "Answer", agent: "assistant")

        let messages = dataManager.fetchMessages(by: convo.id!)
        XCTAssertEqual(messages.first?.agent, "user")
        XCTAssertEqual(messages.last?.agent, "assistant")
    }
}
