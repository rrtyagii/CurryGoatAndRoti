//
//  TopicDetailView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/28/26.
//

import SwiftUI

struct TopicDetailView: View {
    let scrum: CardDetail
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var topicLibrary: TopicLibrary
    @Environment(\.theme) var theme
    @State private var topicContent = ""
    @FetchRequest private var bookmarks: FetchedResults<Bookmark>

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
