//
//  GameProgressBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/7/9.
//

import SwiftUI

struct GameProgressBar: View {
    var progress: Double

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(#colorLiteral(red: 0.5490196078, green: 0.5490196078, blue: 0.5490196078, alpha: 1)))
                    .frame(height: 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color(#colorLiteral(red: 0, green: 1, blue: 1, alpha: 1)), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(#colorLiteral(red: 0.2588235294, green: 0.3882352941, blue: 0.6470588235, alpha: 1)))
                    .frame(width: max(0, progress * 236), height: 11)
                    .offset(x: 2)
            }
            .frame(width: 240)

            Text(verbatim: "\(Int(progress / 100))%")
                .gameText(color: Color(#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)))
        }
    }
}

#Preview {
    GameProgressBar(progress: 0.5)
}
