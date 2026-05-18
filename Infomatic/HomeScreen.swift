//
//  HomeScreen.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        if #available(iOS 16.0, *){
            NavigationStack {
                HomeScreenContent()
            }
        } else{
            NavigationView{
                HomeScreenContent()
            }
            .navigationViewStyle(.stack)
        }
    }
}

private struct HomeScreenContent: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var topicLibrary: TopicLibrary
    @Environment(\.theme) var theme
    @State private var searchQuery = ""

    @FetchRequest( // Swift Property wrapper for Core Data fetch requests. Allows us to embed data directly. We must provide with a "sortDescriptor".
        sortDescriptors: [NSSortDescriptor(keyPath: \Bookmark.createdAt, ascending: false)],
        predicate: NSPredicate(format: "contentType == %@", CardDetail.bookmarkContentType),
        animation: .default
    ) private var bookmarks: FetchedResults<Bookmark>

    private var bookmarkedIds: Set<String> {
        Set(bookmarks.compactMap(\.contentId))
    }

    private func toggleBookmark(for cardDetail: CardDetail) {
        if bookmarkedIds.contains(cardDetail.bookmarkContentId) {
            dataManager.deleteBookmark(contentType: cardDetail.bookmarkType, contentId: cardDetail.bookmarkContentId)
        } else {
            dataManager.addBookmark(contentType: cardDetail.bookmarkType, contentId: cardDetail.bookmarkContentId)
        }
    }

    private var hasActiveSearch: Bool {
        !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var displayedCards: [CardDetail] {
        if hasActiveSearch {
            return topicLibrary.searchCards(matching: searchQuery).map(\.card)
        }

        return topicLibrary.cards
    }

    private var sectionTitle: String {
        hasActiveSearch ? "Search Results" : "Browse Topics"
    }

    private var emptyStateText: String {
        hasActiveSearch
            ? "No topics matched \"\(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines))\"."
            : "No topics available."
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.textColor.opacity(0.75))

            TextField("Search topics, tags, or keywords", text: $searchQuery)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundStyle(theme.textColor)

            if hasActiveSearch {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.textColor.opacity(0.75))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(theme.lightColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(theme.lightColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var contentColumnWidth: CGFloat {
        340
    }
    
    private var topicContent: some View {
        ZStack{
            LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Welcome, \(authManager.user?.name ?? "User")!")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(theme.textColor)

                searchBar
                    .frame(width: contentColumnWidth)
                
                ScrollView {
                    LazyVStack(spacing: 14) {
                        Text(sectionTitle)
                            .font(.headline)
                            .foregroundStyle(theme.textColor.opacity(0.9))
                            .frame(width: contentColumnWidth, alignment: .leading)

                        if displayedCards.isEmpty {
                            Text(emptyStateText)
                                .font(.subheadline)
                                .foregroundStyle(theme.textColor.opacity(0.8))
                                .frame(width: contentColumnWidth, alignment: .leading)
                        } else {
                            ForEach(displayedCards) { scrum in
                                NavigationLink (destination: TopicDetailView(scrum: scrum)){
                                    CardView(
                                        scrum: scrum,
                                        isBookmarked: bookmarkedIds.contains(scrum.bookmarkContentId),
                                        onToggleBookmark: { toggleBookmark(for: scrum) }
                                    )
                                        .frame(width: contentColumnWidth, height: 150)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 18)
                }
            }
        }
    }

    var body: some View {
        topicContent
    }
}
