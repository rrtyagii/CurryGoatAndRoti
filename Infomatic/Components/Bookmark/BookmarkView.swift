//
//  BookmarkView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 3/12/26.
//

import SwiftUI
import Foundation

struct BookmarkView: View{
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                BookmarkViewContent()
            }
        } else {
            NavigationView {
                BookmarkViewContent()
            }
            .navigationViewStyle(.stack)
        }
    }
}

private struct BookmarkViewContent: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var topicLibrary: TopicLibrary
    @Environment(\.theme) var theme
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bookmark.createdAt, ascending: false)],
        predicate: NSPredicate(format: "contentType == %@", CardDetail.bookmarkContentType),
        animation: .default
    ) private var bookmarks: FetchedResults<Bookmark>

    private var bookmarkedIds: Set<String> {
        Set(bookmarks.compactMap(\.contentId))
    }

    private var bookmarkedCards: [CardDetail] {
        let cardsById = Dictionary(
            topicLibrary.cards.map { ($0.id, $0) },
            uniquingKeysWith: {first, _ in first}
        )
        return bookmarks.compactMap { bookmark in
            guard let id = bookmark.contentId else { return nil }
            return cardsById[id]
        }
    }
    
    private func toggleBookmark(for cardDetail: CardDetail) {
        if bookmarkedIds.contains(cardDetail.bookmarkContentId) {
            dataManager.deleteBookmark(contentType: cardDetail.bookmarkType, contentId: cardDetail.bookmarkContentId)
        } else {
            dataManager.addBookmark(contentType: cardDetail.bookmarkType, contentId: cardDetail.bookmarkContentId)
        }
    }

    private var bookmarkContent: some View {
        ZStack{
            LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Bookmarks")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(theme.textColor)
                
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(bookmarkedCards) { scrum in
                            NavigationLink (destination: TopicDetailView(scrum: scrum)){
                                CardView(
                                    scrum: scrum,
                                    isBookmarked: bookmarkedIds.contains(scrum.bookmarkContentId),
                                    onToggleBookmark: { toggleBookmark(for: scrum) }
                                )
                                    .frame(width: 340, height: 150)
                            }
                        }
                    }
                }
                
            }
        }
    }

    var body: some View {
        bookmarkContent
    }
}
