//
//  NewsDetailView.swift
//  News
//
//  Created by Adnann Muratovic on 02.09.25.
//

import SwiftUI

struct NewsDetailView: View {
    let article: Article

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ArticleHeaderImage(url: article.image)
                ArticleContent(article: article)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

/// Encapsulates all article content except the header image
private struct ArticleContent: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArticleMetaRow(
                category: article.category,
                author: article.author,
                date: article.date
            )

            ArticleTitle(
                title: article.title,
                subtitle: article.subtitle
            )

            Divider()

            ArticleBody(text: article.text)
        }
    }
}

/// Handles title and optional subtitle display
private struct ArticleTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// Handles article body text with proper formatting
private struct ArticleBody: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
            .lineSpacing(2)
    }
}

/// Updated ArticleHeaderImage using ReusableAsyncImage
private struct ArticleHeaderImage: View {
    let url: URL?

    @ScaledMetric(relativeTo: .title2) private var cornerRadius: CGFloat = 14
    @ScaledMetric private var height: CGFloat = 240

    var body: some View {
        ReusableAsyncImage(
            url: url,
            cornerRadius: cornerRadius,
            height: height,
            width: nil,
            contentMode: .fill
        )
    }
}

/// A compact metadata row with improved accessibility
private struct ArticleMetaRow: View {
    let category: String
    let author: String
    let date: String

    var body: some View {
        HStack(spacing: 8) {
            CategoryBadge(text: category)

            MetadataText(text: "by \(author)")
            MetadataSeparator()
            MetadataText(text: date)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category). by \(author). \(date)")
    }
}

/// Reusable metadata text component
private struct MetadataText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

/// Consistent separator for metadata
private struct MetadataSeparator: View {
    var body: some View {
        Text("•")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        NewsDetailView(
            article: .init(
                id: 1,
                title: "SwiftUI Improvements in iOS 17",
                subtitle: "Enhanced layout system and animation capabilities",
                author: "Apple Engineering",
                category: "iOS Development",
                date: "September 2, 2025",
                image: URL(string: "https://picsum.photos/800/400"),
                text: """
                    SwiftUI continues to evolve with each iOS release, bringing developers more powerful tools for creating exceptional user interfaces. The latest improvements focus on performance optimizations, enhanced animation capabilities, and better accessibility support.

                    Key highlights include improved layout performance, more granular control over animations, and enhanced support for custom accessibility actions.
                    """
            ))
    }
}
