//
//  ImageLoaderCache.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import Foundation

@MainActor final class ImageLoaderCache {
    static let shared = ImageLoaderCache()
    private var loaders: [URL: ImageLoader] = [:]

    private init() {}

    func loader(for url: URL) -> ImageLoader {
        if let existingLoader = loaders[url] {
            return existingLoader
        }

        let newLoader = ImageLoader(url: url)
        loaders[url] = newLoader
        return newLoader
    }
}
