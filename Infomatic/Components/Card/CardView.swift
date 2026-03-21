//
//  CardView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//

import SwiftUI

struct CardView: View {
    let cardDetail: CardDetail
    let isBookmarked: Bool
    let onToggleBookmark: () -> Void

    init(scrum: CardDetail, isBookmarked: Bool, onToggleBookmark: @escaping () -> Void) {
        self.cardDetail = scrum
        self.isBookmarked = isBookmarked
        self.onToggleBookmark = onToggleBookmark
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(cardDetail.title)
                    .font(.headline)
                    .foregroundStyle(cardDetail.theme.textColor)

                Spacer()
                
                Button(action: onToggleBookmark){
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(cardDetail.theme.accentColor)
                }
                .buttonStyle(.plain)
            }

            Text(cardDetail.tags.joined(separator: " • "))
                .font(.caption)
                .foregroundStyle(cardDetail.theme.textColor.opacity(0.8))

            Text(cardDetail.preview
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
