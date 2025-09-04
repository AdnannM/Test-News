//
//  LoadingImageView.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import SwiftUI

struct LoadingImageView: View {
    let height: CGFloat
    
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .background(.quaternary)
            .redacted(reason: .placeholder)
    }
}
