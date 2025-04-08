//
//  GameText.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/6.
//

import SwiftUI

struct GameText: View {
    var string: String
    var size: CGFloat

    var body: some View {
        Text(string)
            .font(.custom("Arial", fixedSize: size))
    }

    init(_ string: String, size: CGFloat = 12) {
        self.string = string
        self.size = size
    }
}

#Preview {
    GameText("Novice")
}
