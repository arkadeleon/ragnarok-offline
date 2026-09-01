//
//  MenuView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/8.
//

import SwiftUI

enum MenuItem {
    case status
    case equipment
    case inventory
    case skill
    case worldMap
    case options
}

struct MenuView: View {
    var action: (MenuItem) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            MenuExpandButton(isExpanded: isExpanded) {
                isExpanded.toggle()
            }

            if isExpanded {
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        GameButton("menu_icon/bt_status.bmp") {
                            action(.status)
                        }
                        GameButton("menu_icon/bt_equip.bmp") {
                            action(.equipment)
                        }
                        GameButton("menu_icon/bt_item.bmp") {
                            action(.inventory)
                        }
                        GameButton("menu_icon/bt_skill.bmp") {
                            action(.skill)
                        }
                        GameButton("menu_icon/bt_party.bmp") {
                        }
                        .disabled(true)
                    }
                    .frame(width: 32, height: 34)

                    GridRow {
                        GameButton("menu_icon/bt_guild.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_battle.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_quest.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_map.bmp") {
                            action(.worldMap)
                        }
                        GameButton("menu_icon/bt_navigation.bmp") {
                        }
                        .disabled(true)
                    }
                    .frame(width: 32, height: 34)

                    GridRow {
                        GameButton("menu_icon/bt_option.bmp") {
                            action(.options)
                        }
                        GameButton("menu_icon/bt_bank.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_rec.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_mail.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_achievement.bmp") {
                        }
                        .disabled(true)
                    }
                    .frame(width: 32, height: 34)

                    GridRow {
                        GameButton("menu_icon/bt_tip.bmp") {
                        }
                        GameButton("menu_icon/bt_keyboard.bmp") {
                        }
                        GameButton("menu_icon/bt_attendance.bmp") {
                        }
                        GameButton("menu_icon/bt_adventureragency.bmp") {
                        }
                        GameButton("menu_icon/bt_repute.bmp") {
                        }
                    }
                    .frame(width: 32, height: 34)
                    .disabled(true)
                }
                .padding(10)
                .background(.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
    }

    init(action: @escaping (MenuItem) -> Void) {
        self.action = action
    }
}

private struct MenuExpandButton: View {
    var isExpanded: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 3)
                .fill(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(#colorLiteral(red: 0.9607843137, green: 0.9764705882, blue: 0.9921568627, alpha: 1)),
                                    Color(#colorLiteral(red: 0.9137254902, green: 0.9411764706, blue: 0.9803921569, alpha: 1)),
                                    Color(#colorLiteral(red: 0.8509803922, green: 0.8980392157, blue: 0.9647058824, alpha: 1)),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .padding(1)
                }
                .overlay {
                    GameTriangle()
                        .fill(Color(#colorLiteral(red: 0.2156862745, green: 0.2980392157, blue: 0.4705882353, alpha: 1)))
                        .frame(width: 9, height: 5)
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                }
                .frame(width: 220, height: 12)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuView { item in
        // Perform action.
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
