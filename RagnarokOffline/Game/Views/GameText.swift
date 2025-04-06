//
//  GameText.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/6.
//

import SwiftUI

struct GameText: View {
    var string: String

    var body: some View {
        Text(string)
            .font(.custom("Arial", fixedSize: 12))
    }

    init(_ string: String) {
        self.string = string
    }
}

#Preview {
    GameText("Novice")
}
