//
//  CardView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//

import SwiftUI

struct CardView: View {
    let scrum: CardDetail
    @State private var isBookmarked: Bool

    init(scrum: CardDetail) {
        self.scrum = scrum
        _isBookmarked = State(initialValue: scrum.isBookmark)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(scrum.title)
                    .font(.headline)
                    .foregroundStyle(scrum.theme.textColor)

                Spacer()

                Button {
                    isBookmarked.toggle()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(scrum.theme.accentColor)
                }
            }

            Text(scrum.tags.joined(separator: " • "))
                .font(.caption)
                .foregroundStyle(scrum.theme.textColor.opacity(0.8))

            Text(scrum.content)
                .font(.subheadline)
                .foregroundStyle(scrum.theme.textColor)
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(scrum.theme.primaryColor.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(scrum.theme.lightColor.opacity(0.35), lineWidth: 1)
                
        )
    }
}

#Preview {
    let scrum = CardDetail.sampleData[0]
    CardView(scrum: scrum)
        .frame(width: 340, height: 150)
        .padding()
        .background(scrum.theme.secondaryColor)
}
