//
//  SuccessImageView.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import SwiftUI

struct SuccessImageView: View {
    let image: Image
    let height: CGFloat
    
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .clipped()
            .accessibilityLabel("Article image")
    }
}
