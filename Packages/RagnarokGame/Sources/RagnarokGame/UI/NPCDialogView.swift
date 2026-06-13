//
//  NPCDialogView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/12/16.
//

import RagnarokModels
import SwiftUI

struct NPCDialogView: View {
    var dialog: NPCDialog

    @Environment(GameSession.self) private var gameSession

    @State private var selectedMenuIndex = 0
    @State private var inputValue = ""

    var body: some View {
        GameWindow {
            VStack(spacing: 5) {
                NPCDialogMessageBox(message: dialog.message)

                if let menu = dialog.menu {
                    NPCDialogMenuBox(menu: menu, selectedIndex: $selectedMenuIndex)
                }

                if let input = dialog.input {
                    NPCDialogInputBox(input: input, value: $inputValue)
                }
            }
            .padding(5)
        } bottomBar: {
            GameBottomBar {
                if let input = dialog.input {
                    Button("OK") {
                        confirmInput(input)
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                } else if dialog.menu != nil {
                    Button("OK") {
                        gameSession.selectMenu(UInt8(selectedMenuIndex + 1))
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)

                    Button("Cancel") {
                        gameSession.cancelMenu()
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                } else {
                    switch dialog.action {
                    case .next:
                        Button("Next") {
                            gameSession.requestNextMessage()
                        }
                        .buttonStyle(.game)
                        .frame(width: 42, height: 20)
                    case .close:
                        Button("Close") {
                            gameSession.closeDialog()
                        }
                        .buttonStyle(.game)
                        .frame(width: 42, height: 20)
                    case nil:
                        EmptyView()
                    }
                }
            }
        }
        .frame(width: 280)
        .onChange(of: dialog.menu) {
            selectedMenuIndex = 0
        }
        .onChange(of: dialog.input) {
            inputValue = ""
        }
    }

    private func confirmInput(_ input: NPCDialogInput) {
        switch input {
        case .number:
            gameSession.confirmInput(Int32(inputValue) ?? 0)
        case .text:
            gameSession.confirmInput(inputValue)
        }
        inputValue = ""
    }
}

private struct NPCDialogMessageBox: View {
    var message: String

    var body: some View {
        ScrollView {
            Text(message)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5)
        }
        .frame(height: 130)
        .background(Color(#colorLiteral(red: 0.9372549020, green: 0.9568627451, blue: 0.9411764706, alpha: 1)))
    }
}

private struct NPCDialogMenuBox: View {
    var menu: [String]

    @Binding var selectedIndex: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<menu.count, id: \.self) { index in
                    Text(menu[index])
                        .font(.game())
                        .foregroundStyle(Color.gameLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(selectedIndex == index ? Color(#colorLiteral(red: 0.8039215686, green: 0.8784313725, blue: 1, alpha: 1)) : .clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
        }
        .frame(height: 80)
        .background(Color(#colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)))
    }
}

private struct NPCDialogInputBox: View {
    var input: NPCDialogInput

    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(verbatim: input == .number ? "Input number" : "Input text")
                .font(.game())
                .foregroundStyle(Color.gameLabel)

            TextField("", text: $value)
                .textFieldStyle(.plain)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .padding(.horizontal, 3)
                .frame(height: 18)
                .background(Color(#colorLiteral(red: 0.9372549020, green: 0.9372549020, blue: 0.9372549020, alpha: 1)))
                #if !os(macOS)
                .keyboardType(input == .number ? .numberPad : .default)
                #endif
        }
    }
}

#Preview {
    let dialog: NPCDialog = {
        let message = """
        [Wounded]
        Wow! Thanks a lot!
        I don't know how this happened to our ship
        but we should go to see the captain.
        """
        let dialog = NPCDialog(npcID: 0, message: message)
        dialog.action = .next
        dialog.menu = [
            "Go to the captain",
            "Stay here",
        ]
        return dialog
    }()

    NPCDialogView(dialog: dialog)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
