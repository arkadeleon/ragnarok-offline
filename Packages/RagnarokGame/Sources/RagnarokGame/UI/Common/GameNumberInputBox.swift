//
//  GameNumberInputBox.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/29.
//

import SwiftUI

struct GameNumberInputBox: View {
    var message: String
    var bounds: ClosedRange<Int>
    var onSubmit: ((Int) -> Void)?
    var onClose: (() -> Void)?

    @State private var value: Int

    var body: some View {
        GameWindow {
            VStack(spacing: 8) {
                Text(message)
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .lineLimit(1)

                GameStepper(value: $value, in: bounds)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
        } bottomBar: {
            GameBottomBar {
                // btn_ok.bmp
                Button {
                    onSubmit?(value)
                } label: {
                    Text("OK", bundle: #bundle)
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
        }
        .gameWindowCloseAction {
            onClose?()
        }
        .frame(width: 200)
    }

    init(
        _ message: String,
        bounds: ClosedRange<Int>,
        onSubmit: ((Int) -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.message = message
        self.bounds = bounds
        self.onSubmit = onSubmit
        self.onClose = onClose
        self._value = State(initialValue: bounds.lowerBound)
    }
}

#Preview {
    GameNumberInputBox("Red Potion", bounds: 1...10)
        .padding()
}
