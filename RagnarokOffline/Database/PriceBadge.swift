//
//  PriceBadge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct PriceBadge: View {
    var price: Int

    var body: some View {
        Badge(text: price.formatted() + "z", color: .orange)
    }
}
