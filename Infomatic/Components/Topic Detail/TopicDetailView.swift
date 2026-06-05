//
//  TopicDetailView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/28/26.
//

import SwiftUI

struct Messages: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
    
    init(text: String, isFromUser: Bool) {
        self.text = text
        self.isFromUser = isFromUser
    }
}

struct MessageBubble: View {
    let messages: Messages
    
    var body: some View{
        HStack {
            if messages.isFromUser { Spacer() }
            
            Text(messages.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(messages.isFromUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(messages.isFromUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(maxWidth: 280, alignment: messages.isFromUser ? .trailing : .leading)
            
            if !messages.isFromUser { Spacer() }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }
}

struct BottomSheetView: View{
    @Environment(\.theme) var theme
    @State private var messages: [Messages] = [Messages(text: "How can I help you today", isFromUser: false)]
    @State private var userInputText: String = ""
    
    private func sendMessage(){
        let trimmedText = userInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Append user message
        let newMessage = Messages(text: trimmedText, isFromUser: true)
        messages.append(newMessage)
        userInputText = ""
        
        // Simulate a mock bot reply after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let botMessage = Messages(text: "This is an automated response to: \"\(trimmedText)\"", isFromUser: false)
            messages.append(botMessage)
        }
    }
    
    var body: some View{
        VStack(spacing: 18) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(messages){ message in
                            MessageBubble(messages: message)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("What do you have on your mind ?", text: $userInputText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(userInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .disabled(userInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
}

struct TopicDetailView: View {
    let scrum: CardDetail
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var topicLibrary: TopicLibrary
    @Environment(\.theme) var theme
    @State private var topicContent = ""
    @FetchRequest private var bookmarks: FetchedResults<Bookmark>
    @State private var showAskSheet: Bool = false

    init(scrum: CardDetail) {
        self.scrum = scrum
        _bookmarks = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Bookmark.createdAt, ascending: false)],
            predicate: NSPredicate(
                format: "contentType == %@ AND contentId == %@",
                scrum.bookmarkType,
                scrum.bookmarkContentId
            ),
            animation: .default
        )
    }

    private var isBookmarked: Bool {
        !bookmarks.isEmpty
    }

    private func toggleBookmark() {
        if isBookmarked {
            dataManager.deleteBookmark(contentType: scrum.bookmarkType, contentId: scrum.bookmarkContentId)
        } else {
            dataManager.addBookmark(contentType: scrum.bookmarkType, contentId: scrum.bookmarkContentId)
        }
    }
    
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16){
                HStack(alignment: .top) {
                    Text(scrum.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(scrum.theme.textColor)

                    Spacer()

                    Button {
                        toggleBookmark()
                    }label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(scrum.theme.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                ScrollView{
                    LazyVStack(spacing: 14){
                        Text(scrum.tags.joined(separator: " • "))
                            .font(.caption)
                            .foregroundStyle(scrum.theme.textColor.opacity(0.8))

                        Text(self.topicContent)
                            .font(.headline)
                            .foregroundStyle(scrum.theme.textColor)
                    }
                }
                Button("Ask me!"){
                    showAskSheet.toggle()
                }
                .sheet(isPresented: $showAskSheet) {
                    BottomSheetView()
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(scrum.theme.primaryColor.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onAppear {
                if topicContent.isEmpty {
                    topicContent = topicLibrary.content(for: scrum)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(scrum.theme.lightColor.opacity(0.35), lineWidth: 1)
                    
            )
        }
    }
}

#Preview {
    let dataManager = DataManager(inMemory: true)
    let sampleCard = CardDetail(
        id: "neural-network",
        tags: ["neural", "networks", "machine learning"],
        title: "Neural Network",
        preview: "A neural network is a computational model inspired by biological neural systems.",
        contentFile: "topics/neural-network.txt"
    )

    TopicDetailView(scrum: sampleCard)
        .environmentObject(dataManager)
        .environmentObject(TopicLibrary(cards: [sampleCard]))
        .environment(\.managedObjectContext, dataManager.context)
        .environment(\.theme, .standard)
}
