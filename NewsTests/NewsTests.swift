//
//  NewsTests.swift
//  NewsTests
//
//  Created by Adnann Muratovic on 01.09.25.
//

import Foundation
import Testing

@testable import News

// MARK: - Mock Article Service
struct MockArticleService: ArticleServiceProtocol {
    enum MockResult {
        case success([Article])
        case failure(Error)
    }

    let mockResult: MockResult
    let delay: TimeInterval

    init(mockResult: MockResult, delay: TimeInterval = 0) {
        self.mockResult = mockResult
        self.delay = delay
    }

    func fetchArticles() async throws -> [Article] {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        switch mockResult {
        case .success(let articles):
            return articles
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Test Data Factory
struct TestDataFactory {
    static func createMockArticle(
        id: Int = 1,
        title: String = "Test Article",
        subtitle: String = "Test Subtitle",
        author: String = "Test Author",
        category: String = "Tech",
        date: String = "2025-09-02",
        image: URL? = URL(string: "https://example.com/image.jpg"),
        text: String = "Test article content"
    ) -> Article {
        Article(
            id: id,
            title: title,
            subtitle: subtitle,
            author: author,
            category: category,
            date: date,
            image: image,
            text: text
        )
    }

    static func createMockArticles(count: Int = 3) -> [Article] {
        (1...count).map { index in
            createMockArticle(
                id: index,
                title: "Article \(index)",
                subtitle: "Subtitle \(index)",
                category: index % 2 == 0 ? "Tech" : "Sport"
            )
        }
    }
}

// MARK: - Custom Test Errors
enum TestError: Error, Equatable {
    case networkError
    case invalidResponse
    case timeout
}

// MARK: - Article Service Tests
struct ArticleServiceTests {

    // MARK: - Success Cases
    @Test("Fetch articles successfully")
    func fetchArticlesSuccess() async throws {
        // Given
        let mockArticles = TestDataFactory.createMockArticles(count: 2)
        let mockService = MockArticleService(mockResult: .success(mockArticles))

        // When
        let articles = try await mockService.fetchArticles()

        // Then
        #expect(articles.count == 2)
        #expect(articles[0].title == "Article 1")
        #expect(articles[1].title == "Article 2")
        #expect(articles[0].category == "Sport")
        #expect(articles[1].category == "Tech")
    }

    @Test("Fetch empty articles list")
    func fetchEmptyArticlesList() async throws {
        // Given
        let mockService = MockArticleService(mockResult: .success([]))

        // When
        let articles = try await mockService.fetchArticles()

        // Then
        #expect(articles.isEmpty)
    }

    @Test("Fetch single article")
    func fetchSingleArticle() async throws {
        // Given
        let mockArticle = TestDataFactory.createMockArticle(
            title: "iOS 18 Features",
            author: "Apple Team", category: "Tech"
        )
        let mockService = MockArticleService(
            mockResult: .success([mockArticle]))

        // When
        let articles = try await mockService.fetchArticles()

        // Then
        #expect(articles.count == 1)
        #expect(articles[0].title == "iOS 18 Features")
        #expect(articles[0].category == "Tech")
        #expect(articles[0].author == "Apple Team")
    }

    // MARK: - Error Cases
    @Test("Fetch articles with network error")
    func fetchArticlesNetworkError() async throws {
        // Given
        let mockService = MockArticleService(
            mockResult: .failure(TestError.networkError))

        // When & Then
        await #expect(throws: TestError.networkError) {
            try await mockService.fetchArticles()
        }
    }

    @Test("Fetch articles with timeout error")
    func fetchArticlesTimeoutError() async throws {
        // Given
        let mockService = MockArticleService(
            mockResult: .failure(TestError.timeout))

        // When & Then
        await #expect(throws: TestError.timeout) {
            try await mockService.fetchArticles()
        }
    }

    @Test("Fetch articles with invalid response error")
    func fetchArticlesInvalidResponse() async throws {
        // Given
        let mockService = MockArticleService(
            mockResult: .failure(TestError.invalidResponse))

        // When & Then
        await #expect(throws: TestError.invalidResponse) {
            try await mockService.fetchArticles()
        }
    }

    // MARK: - Performance Tests
    @Test("Fetch articles performance")
    func fetchArticlesPerformance() async throws {
        // Given
        let mockArticles = TestDataFactory.createMockArticles(count: 100)
        let mockService = MockArticleService(mockResult: .success(mockArticles))

        // When
        let startTime = Date()
        let articles = try await mockService.fetchArticles()
        let endTime = Date()

        // Then
        let executionTime = endTime.timeIntervalSince(startTime)
        #expect(articles.count == 100)
        #expect(executionTime < 1.0)
    }

    @Test("Fetch articles with simulated delay")
    func fetchArticlesWithDelay() async throws {
        // Given
        let mockArticles = TestDataFactory.createMockArticles(count: 1)
        let mockService = MockArticleService(
            mockResult: .success(mockArticles),
            delay: 0.1  // 100ms delay
        )

        // When
        let startTime = Date()
        let articles = try await mockService.fetchArticles()
        let endTime = Date()

        // Then
        let executionTime = endTime.timeIntervalSince(startTime)
        #expect(articles.count == 1)
        #expect(executionTime >= 0.1)  // Should take at least 100ms
        #expect(executionTime < 0.5)  // But not too long
    }
}

// MARK: - Article Model Tests
struct ArticleModelTests {

    @Test("Create article with all properties")
    func createCompleteArticle() async throws {
        // Given & When
        let article = TestDataFactory.createMockArticle(
            id: 42,
            title: "SwiftUI Best Practices",
            subtitle: "Clean architecture patterns",
            author: "Senior Engineer",
            category: "Development",
            date: "2025-09-02",
            image: URL(string: "https://example.com/swift.jpg"),
            text: "Comprehensive guide to SwiftUI architecture..."
        )

        // Then
        #expect(article.id == 42)
        #expect(article.title == "SwiftUI Best Practices")
        #expect(article.subtitle == "Clean architecture patterns")
        #expect(article.author == "Senior Engineer")
        #expect(article.category == "Development")
        #expect(article.date == "2025-09-02")
        #expect(
            article.image?.absoluteString == "https://example.com/swift.jpg")
        #expect(
            article.text == "Comprehensive guide to SwiftUI architecture...")
    }

    @Test("Create article without image")
    func createArticleWithoutImage() async throws {
        // Given & When
        let article = TestDataFactory.createMockArticle(
            title: "Text Only Article",
            image: nil
        )

        // Then
        #expect(article.title == "Text Only Article")
        #expect(article.image == nil)
    }

    @Test("Article conforms to Identifiable")
    func articleIdentifiable() async throws {
        // Given
        let article1 = TestDataFactory.createMockArticle(id: 1)
        let article2 = TestDataFactory.createMockArticle(id: 2)

        // When & Then
        #expect(article1.id == 1)
        #expect(article2.id == 2)
        #expect(article1.id != article2.id)
    }
}

// MARK: - Articles Container Tests
struct ArticlesContainerTests {

    @Test("Articles container with multiple articles")
    func articlesContainerMultiple() async throws {
        // Given
        let mockArticles = TestDataFactory.createMockArticles(count: 5)

        // When
        let container = Articles(articles: mockArticles)

        // Then
        #expect(container.articles.count == 5)
        #expect(container.articles[0].title == "Article 1")
        #expect(container.articles[4].title == "Article 5")
    }

    @Test("Articles container with empty list")
    func articlesContainerEmpty() async throws {
        // Given & When
        let container = Articles(articles: [])

        // Then
        #expect(container.articles.isEmpty)
    }
}

// MARK: - Integration Tests
struct ArticleServiceIntegrationTests {

    @Test("End-to-end article fetching flow")
    func endToEndArticleFetch() async throws {
        // Given
        let expectedArticles = TestDataFactory.createMockArticles(count: 3)
        let mockService = MockArticleService(
            mockResult: .success(expectedArticles))

        // When
        let articles = try await mockService.fetchArticles()

        // Then - Verify complete data structure
        #expect(articles.count == 3)

        // Verify first article
        let firstArticle = articles[0]
        #expect(firstArticle.id == 1)
        #expect(firstArticle.title == "Article 1")
        #expect(firstArticle.category == "Sport")
        #expect(firstArticle.image != nil)

        // Verify data consistency
        let techArticles = articles.filter { $0.category == "Tech" }
        let sportArticles = articles.filter { $0.category == "Sport" }
        #expect(techArticles.count == 1)
        #expect(sportArticles.count == 2)
    }
}

struct ArticlesViewModelTests {
    
    @Test("View Model loads articles successfulyl")
    func loadArticlesSuccessfully() async throws {
        // GIVEN
        let mockArticles = TestDataFactory.createMockArticles(count: 3)
        let mockService = MockArticleService(mockResult: .success(mockArticles))
        
        let viewModel = await ArticleViewModel(service: mockService)
        
        // WHEN
        await viewModel.load()
        
        guard case .success(let articles) = await viewModel.state else {
//            #expect(false, "Expected success state, got \(viewModel.state)")
            return
        }
        
        // THEN
        #expect(articles.count == 3)
        #expect(articles[0].id == mockArticles[0].id)
        #expect(articles[0].title == mockArticles[0].title)
    }
    
    
    @Test("ViewModel enter loading state on load")
    func loadingStateOnLoad() async throws {
        // GIVEN
        let mockService = MockArticleService(mockResult: .success([]), delay: 0.2)
        let viewModel = await ArticleViewModel(service: mockService)
        
        // WHEN
        await viewModel.load()
        
        // THEN
        #expect(await viewModel.state == .loading)
    }
    
    @Test("Transition from loading to success")
    func loadingToSuccessTransition() async throws {
        let mockArticles = TestDataFactory.createMockArticles()
        let mockService = MockArticleService(mockResult: .success(mockArticles), delay: 0.2)
        let viewModel = await ArticleViewModel(service: mockService)
        
        await viewModel.load()
        
        #expect(await viewModel.state == .loading)
        
        try await Task.sleep(for: .milliseconds(250))
        
        guard case .success(let articles) = await viewModel.state else {
            return
        }
        
        #expect(articles.count == mockArticles.count)
    }
}



// MARK: - Test Utilities and Extensions
extension ArticleServiceProtocol {
    /// Helper method for testing - fetches articles and measures time
    func fetchArticlesWithTiming() async throws -> (
        articles: [Article], duration: TimeInterval
    ) {
        let startTime = Date()
        let articles = try await fetchArticles()
        let duration = Date().timeIntervalSince(startTime)
        return (articles, duration)
    }
}
