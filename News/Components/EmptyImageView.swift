//
//  EmptyImageView.swift
//  News
//
//  Created by Adnann Muratovic on 03.09.25.
//

import SwiftUI

struct EmptyImageView: View {
    let height: CGFloat
    
    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
    }
}
