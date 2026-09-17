//
//  GameSymbolButton.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/17.
//

import SwiftUI

struct GameSymbolButton: View {
    var symbol: GameSymbol
    var action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            // Extend the hit area beyond the drawn 18×18 button.
            Color.clear
                .frame(width: 18, height: 18)
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(GameSymbolButtonStyle(symbol: symbol))
        .padding(-8)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

private struct GameSymbolButtonStyle: ButtonStyle {
    var symbol: GameSymbol

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                GameSymbolView(symbol: symbol, isPressed: configuration.isPressed)
            }
            .background {
                GameSymbolButtonBackground(isPressed: configuration.isPressed)
                    .padding(8)
            }
    }
}

private struct GameSymbolButtonBackground: View {
    var isPressed: Bool

    var body: some View {
        Rectangle()
            .fill(isPressed ? Color(#colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)) : Color(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1)))
            .padding(1)
            .overlay {
                let topLeading = isPressed ? Color(#colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)) : Color(#colorLiteral(red: 0.9686274510, green: 0.9686274510, blue: 0.9686274510, alpha: 1))
                let bottomTrailing = isPressed ? Color(#colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)) : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                VStack(spacing: 0) {
                    topLeading.frame(height: 1)
                    HStack(spacing: 0) {
                        topLeading.frame(width: 1)
                        Color.clear
                        bottomTrailing.frame(width: 1)
                    }
                    bottomTrailing.frame(height: 1)
                }
                .padding(1)
            }
            .border(isPressed ? Color(#colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)) : Color(#colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7764705882, alpha: 1)))
    }
}

#Preview {
    HStack(spacing: 12) {
        GameSymbolButton(symbol: .minus) {
        }

        GameSymbolButton(symbol: .plus) {
        }
    }
    .padding()
}
