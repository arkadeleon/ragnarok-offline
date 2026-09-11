//
//  GameStripeView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/11.
//

import SwiftUI

struct GameStripeView: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                let stripe = Path(CGRect(x: 0, y: y, width: size.width, height: 2))
                context.fill(stripe, with: .color(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1))))
                y += 4
            }
        }
        .background(Color.white)
    }
}

#Preview {
    GameStripeView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
