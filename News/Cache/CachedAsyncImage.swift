//
//  CachedAsyncImage.swift
//  News
//
//  Created by Adnann Muratovic on 02.09.25.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    @ObservedObject private var loader: ImageLoader
    private let content: (AsyncImagePhase) -> Content

    init(url: URL, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.loader = ImageLoaderCache.shared.loader(for: url)
        self.content = content
    }

    var body: some View {
        content(phase)
    }

    private var phase: AsyncImagePhase {
        if let image = loader.image {
            return .success(Image(uiImage: image))
        } else if let error = loader.error {
            return .failure(error)
        } else {
            return .empty
        }
    }
}

extension URLCache {
    static let images = URLCache(
        memoryCapacity: 128 * 1_024 * 1_024,
        diskCapacity: 256 * 1_024 * 1_024,
        diskPath: "image-cache"
    )
    
    static func clearImageCache() {
        URLCache.images.removeAllCachedResponses()
    }
}
