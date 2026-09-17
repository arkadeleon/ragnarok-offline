//
//  GameStepper.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/17.
//

import SwiftUI

struct GameStepper: View {
    @Binding var value: Int
    var bounds: ClosedRange<Int>

    @State private var text = ""

    var body: some View {
        HStack(spacing: 5) {
            GameSymbolButton(symbol: .minus) {
                value = max(value - 1, bounds.lowerBound)
            }
            .disabled(value <= bounds.lowerBound)

            TextField("", text: $text)
                .textFieldStyle(.plain)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .multilineTextAlignment(.center)
                .frame(width: 36, height: 18)
                .background(Color(#colorLiteral(red: 0.9686274510, green: 0.9686274510, blue: 0.9686274510, alpha: 1)))
                .border(Color(#colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7764705882, alpha: 1)))
                #if !os(macOS)
                .keyboardType(.numberPad)
                #endif
                .onSubmit {
                    var newValue = Int(text) ?? bounds.lowerBound
                    newValue = max(newValue, bounds.lowerBound)
                    newValue = min(newValue, bounds.upperBound)
                    value = newValue
                }

            GameSymbolButton(symbol: .plus) {
                value = min(value + 1, bounds.upperBound)
            }
            .disabled(value >= bounds.upperBound)
        }
        .onChange(of: value, initial: true) {
            text = "\(value)"
        }
    }

    init(value: Binding<Int>, in bounds: ClosedRange<Int>) {
        self._value = value
        self.bounds = bounds
    }
}

#Preview {
    @Previewable @State var value = 5

    GameStepper(value: $value, in: 0...10)
        .padding()
}
