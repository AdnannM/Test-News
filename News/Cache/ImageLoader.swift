//
//  ImageLoader.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import Observation
import SwiftUI
import os

private let log = Logger(
    subsystem: "com.muratovic.adnann.News",
    category: "ImageLoader"
)

@MainActor final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var error: Error?

    private let url: URL
    private var task: Task<Void, Never>?

    init(url: URL) {
        self.url = url
        self.task = Task { await load() }
    }

    deinit {
        task?.cancel()
    }

    private func load() async {
        var req = URLRequest(url: url)
        req.cachePolicy = .returnCacheDataElseLoad

        // Check cache first
        if let cached = URLCache.images.cachedResponse(for: req),
            let img = UIImage(data: cached.data)
        {
            log.debug(
                "Loaded from cache: \(self.url.lastPathComponent, privacy: .public)"
            )
            self.image = img
            return
        }

        // Load from network
        do {
            log.info(
                "Loading from network: \(self.url.lastPathComponent, privacy: .public)"
            )
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let img = UIImage(data: data) {
                URLCache.images.storeCachedResponse(
                    CachedURLResponse(response: resp, data: data), for: req)
                log.info(
                    "Cached successfully: \(self.url.lastPathComponent, privacy: .public)"
                )
                self.image = img
            } else {
                throw URLError(.cannotDecodeContentData)
            }
        } catch {
            log.error(
                "Failed to load: \(self.url.lastPathComponent, privacy: .public) - \(error.localizedDescription, privacy: .public)"
            )
            self.error = error
        }
    }
}
