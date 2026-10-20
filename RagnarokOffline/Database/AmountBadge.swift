//
//  AmountBadge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct AmountBadge: View {
    var amount: Int

    var body: some View {
        Badge(text: "×" + amount.formatted(), color: .teal)
    }
}
