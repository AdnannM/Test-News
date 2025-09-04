//
//  NewsListView.swift
//  News
//
//  Created by Adnann Muratovic on 02.09.25.
//

import SwiftUI

struct NewsListView: View {
    let articles: [Article]
    let onRefresh: () async -> Void

    var body: some View {
        List(articles) { article in
            NavigationLink {
                NewsDetailView(article: article)
            } label: {
                NewsRowView(article: article)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await onRefresh()
        }
    }
}
