//
//  ReusableAsyncImage.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import SwiftUI

struct ReusableAsyncImage: View {
    let url: URL?
    let cornerRadius: CGFloat
    let height: CGFloat
    let width: CGFloat?
    let contentMode: ContentMode
    
    init(
        url: URL?,
        cornerRadius: CGFloat = 8,
        height: CGFloat = 100,
        width: CGFloat? = nil,
        contentMode: ContentMode = .fill
    ) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.height = height
        self.width = width
        self.contentMode = contentMode
    }
    
    var body: some View {
        content
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .contentShape(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
    }
    
    @ViewBuilder
    private var content: some View {
        if let url {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    LoadingImageView(height: height)
                case .success(let image):
                    SuccessImageView(image: image, height: height)
                case .failure:
                    FailureImageView(height: height)
                @unknown default:
                    EmptyImageView(height: height)
                }
            }
        } else {
            FailureImageView(height: height)
        }
    }
}
