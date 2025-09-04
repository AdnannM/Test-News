//
//  NewsRowView.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import SwiftUI

struct NewsRowView: View {
    let article: Article

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ArticleImageView(imageURL: article.image)
            ArticleContentView(article: article)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

/// Article Image
struct ArticleImageView: View {
    let imageURL: URL?
    
    var body: some View {
        Group {
            if let url = imageURL {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                    case .failure, .empty:
                        placeholderImage
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .frame(width: 80, height: 80)
            .background(.quaternary)
    }
}

/// Article Details
struct ArticleContentView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.headline)
                .lineLimit(2)

            Text(article.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 8) {
                CategoryBadge(text: article.category)
                Text(article.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
