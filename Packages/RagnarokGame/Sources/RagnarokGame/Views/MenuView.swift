//
//  MenuView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/8.
//

import SwiftUI

enum MenuItem {
    case status
    case inventory
    case options
}

struct MenuView: View {
    var action: (MenuItem) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            if !isExpanded {
                GameButton("menu_icon/bt_menu_normal.bmp") {
                    isExpanded.toggle()
                }
                .frame(width: 219, height: 9)
            } else {
                GameButton("menu_icon/bt_menu_close_normal.bmp") {
                    isExpanded.toggle()
                }
                .frame(width: 219, height: 9)
            }

            if isExpanded {
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        GameButton("menu_icon/bt_status.bmp") {
                            action(.status)
                        }
                        GameButton("menu_icon/bt_equip.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_item.bmp") {
                            action(.inventory)
                        }
                        GameButton("menu_icon/bt_skill.bmp") {
                        }
                        .disabled(true)
                        GameButton("menu_icon/bt_party.bmp") {
                        }
                        .disabled(true)
                    }
                    .frame(width: 32, height: 34)

                    GridRow {
                        GameButton("menu_icon/bt_guild.bmp") {
                        }
                        GameButton("menu_icon/bt_battle.bmp") {
                        }
                        GameButton("menu_icon/bt_quest.bmp") {
                        }
                        GameButton("menu_icon/bt_map.bmp") {
                        }
                        GameButton("menu_icon/bt_navigation.bmp") {
                        }
                    }
                    .frame(width: 32, height: 34)
                    .disabled(true)

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
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }

    init(action: @escaping (MenuItem) -> Void) {
        self.action = action
    }
}

#Preview {
    MenuView { item in
        // Perform action.
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(GameSession.testing)
}
