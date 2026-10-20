//
//  RateBadge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct RateBadge: View {
    var rate: Int

    var body: some View {
        Badge(text: (Double(rate) / 100).formatted() + "%", color: .blue)
    }
}
