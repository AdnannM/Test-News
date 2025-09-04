//
//  CategoryBadge.swift
//  News
//
//  Created by Adnann Muratovic on 02.09.25.
//

import SwiftUI

struct CategoryBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.12))
            )
    }
}
