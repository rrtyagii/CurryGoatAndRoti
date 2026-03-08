//
//  CardView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//

import SwiftUI

struct CardView: View {
    let cardDetail: CardDetail
    @State private var isBookmarked: Bool

    init(scrum: CardDetail) {
        self.cardDetail = scrum
        _isBookmarked = State(initialValue: scrum.isBookmark)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(cardDetail.title)
                    .font(.headline)
                    .foregroundStyle(cardDetail.theme.textColor)

                Spacer()

                Button {
                    isBookmarked.toggle()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(cardDetail.theme.accentColor)
                }
            }

            Text(cardDetail.tags.joined(separator: " • "))
                .font(.caption)
                .foregroundStyle(cardDetail.theme.textColor.opacity(0.8))

            Text(
                cardDetail.preview
                    .replacingOccurrences(of: #"\s+"#, with: " ",
            options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
                .font(.subheadline)
                .foregroundStyle(cardDetail.theme.textColor)
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardDetail.theme.primaryColor.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardDetail.theme.lightColor.opacity(0.35), lineWidth: 1)
                
        )
    }
}
