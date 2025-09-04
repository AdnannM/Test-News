//
//  ArticleService.swift
//  News
//
//  Created by Adnann Muratovic on 01.09.25.
//

import Foundation

protocol ArticleServiceProtocol {
    func fetchArticles() async throws -> [Article]
}

struct ArticleService: ArticleServiceProtocol {
    func fetchArticles() async throws -> [Article] {
        let env: Articles = try await APIClient.shared.get(
            Articles.self,
            from: Constants.Api.baseURL
        )

        return env.articles
    }
}
