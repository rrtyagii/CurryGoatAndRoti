//
//  TopicDetailView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/28/26.
//

import SwiftUI

struct TopicDetailView: View {
    let scrum: CardDetail
    @State private var isBookmarked: Bool
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.theme) var theme
    
    init(scrum: CardDetail) {
        self.scrum = scrum
        _isBookmarked = State(initialValue: scrum.isBookmark)
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
                        isBookmarked.toggle()
                    }label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(scrum.theme.accentColor)
                    }
                }
                Text(scrum.tags.joined(separator: " • "))
                    .font(.caption)
                    .foregroundStyle(scrum.theme.textColor.opacity(0.8))

                Text(scrum.content)
                    .font(.headline)
                    .foregroundStyle(scrum.theme.textColor)
            }
            .padding(18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(scrum.theme.primaryColor.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(scrum.theme.lightColor.opacity(0.35), lineWidth: 1)
                    
            )
        }
    }
}

#Preview {
    let scrum = CardDetail.sampleData[0]
    TopicDetailView(scrum: scrum)
        .environmentObject(AuthenticationManager(user: nil, isAuthenticated: false))
        .environment(\.theme, .standard)
        .frame(width: 340)
        .padding()
        .background(scrum.theme.secondaryColor)
    
}
