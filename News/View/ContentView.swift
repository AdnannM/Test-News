//
//  ContentView.swift
//  News
//
//  Created by Adnann Muratovic on 01.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var vm = ArticleViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("News")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button("Clear Cache") {
                            URLCache.clearImageCache()
                        }
                    }
                }
        }
        .task { vm.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failure(let error):
            ErrorView(message: error.localizedDescription) { vm.load() }
        case .success(let articles):
            NewsListView(articles: articles) {
                await vm.refresh(keepCurrentVisible: true)
            }
        }
    }
}
