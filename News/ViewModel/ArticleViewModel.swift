//
//  SubscriptionViewModel.swift
//  News
//
//  Created by Adnann Muratovic on 02.09.25.
//

import SwiftUI
import Observation

enum LoadState<T>: Equatable {
    case idle
    case loading
    case success(T)
    case failure(APIError)
    
    static func == (lhs: LoadState<T>, rhs: LoadState<T>) -> Bool {
        switch(lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}

@Observable @MainActor final class ArticleViewModel {
    
    private(set) var state: LoadState<[Article]> = .idle
    private let service: ArticleServiceProtocol
    private var isRefreshing = false
    
    init(service: ArticleServiceProtocol = ArticleService()) {
        self.service = service
    }
    
    func load() {
        state = .loading
        Task { await refresh(keepCurrentVisible: false) }
    }
    
    /// Pull-to-refresh: keep current list visible
    func refresh(keepCurrentVisible: Bool = false) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            let items = try await service.fetchArticles()
            if case .success = state, keepCurrentVisible {
                withAnimation(.easeInOut(duration: 0.2)) {
                    state = .success(items)
                }
            } else {
                state = .success(items)
            }
        } catch let api as APIError {
            if case .success = state, keepCurrentVisible {
                // Keep current data visible, don't show error
            } else {
                state = .failure(api)
            }
        } catch {
            if case .success = state, keepCurrentVisible {
                // Keep current data visible, don't show error
            } else {
                state = .failure(.other(error))
            }
        }
    }
}
