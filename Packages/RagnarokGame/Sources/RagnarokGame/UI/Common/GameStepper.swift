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
            GameStepperButton(symbol: .minus) {
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

            GameStepperButton(symbol: .plus) {
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

private struct GameStepperButton: View {
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
        .buttonStyle(GameStepperButtonStyle(symbol: symbol))
        .padding(-8)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

private struct GameStepperButtonStyle: ButtonStyle {
    var symbol: GameSymbol

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                ZStack {
                    symbol
                        .fill(configuration.isPressed ? Color(#colorLiteral(red: 0.4313725490, green: 0.5176470588, blue: 0.7764705882, alpha: 1)) : Color(#colorLiteral(red: 0.4549019608, green: 0.5490196078, blue: 0.8196078431, alpha: 1)))
                    symbol
                        .stroke(configuration.isPressed ? Color(#colorLiteral(red: 0.4274509804, green: 0.4588235294, blue: 0.5607843137, alpha: 1)) : Color(#colorLiteral(red: 0.4509803922, green: 0.4862745098, blue: 0.5921568627, alpha: 1)))
                }
                .frame(width: 9, height: 9)
            }
            .background {
                GameStepperButtonBackground(isPressed: configuration.isPressed)
                    .padding(8)
            }
    }
}

private struct GameStepperButtonBackground: View {
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
    @Previewable @State var value = 5

    GameStepper(value: $value, in: 0...10)
        .padding()
}
