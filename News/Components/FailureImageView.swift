//
//  FailureImageView.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import SwiftUI

struct FailureImageView: View {
    let height: CGFloat
    
    var body: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: height * 0.6, height: height * 0.6)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .foregroundStyle(.secondary)
            .background(.quaternary)
            .accessibilityLabel("Image unavailable")
    }
}
