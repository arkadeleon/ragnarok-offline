//
//  StatusView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/8.
//

import ROConstants
import ROGame
import RONetwork
import SwiftUI

struct StatusView: View {
    var status: CharacterStatus

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar()

            ZStack(alignment: .topLeading) {
                GameImage("statuswnd/w_statwin_bg.bmp")

                VStack(spacing: 2) {
                    Group {
                        GameText("\(status.str)")
                        GameText("\(status.agi)")
                        GameText("\(status.vit)")
                        GameText("\(status.int)")
                        GameText("\(status.dex)")
                        GameText("\(status.luk)")
                    }
                    .frame(height: 14)
                }
                .offset(x: 37, y: 6)

                VStack(spacing: 2) {
                    Group {
                        GameText("+\(status.str2)")
                        GameText("+\(status.agi2)")
                        GameText("+\(status.vit2)")
                        GameText("+\(status.int2)")
                        GameText("+\(status.dex2)")
                        GameText("+\(status.luk2)")
                    }
                    .frame(height: 14)
                }
                .offset(x: 54, y: 6)

                VStack(spacing: 2) {
                    Group {
                        GameButton("basic_interface/arw_right.bmp") {
                            gameSession.incrementStatusProperty(.str)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            gameSession.incrementStatusProperty(.agi)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            gameSession.incrementStatusProperty(.vit)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            gameSession.incrementStatusProperty(.int)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            gameSession.incrementStatusProperty(.dex)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            gameSession.incrementStatusProperty(.luk)
                        }
                    }
                    .frame(width: 14, height: 14)
                }
                .offset(x: 75, y: 6)

                VStack(spacing: 2) {
                    Group {
                        GameText("\(status.str3)")
                        GameText("\(status.agi3)")
                        GameText("\(status.vit3)")
                        GameText("\(status.int3)")
                        GameText("\(status.dex3)")
                        GameText("\(status.luk3)")
                    }
                    .frame(width: 14, height: 14, alignment: .trailing)
                }
                .offset(x: 87, y: 6)

                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Group {
                            GameText("\(status.atk) + \(status.atk2)")
                            GameText("\(status.matk) + \(status.matk2)")
                            GameText("\(status.hit)")
                            GameText("\(status.critical)")
                        }
                        .frame(height: 14)
                    }
                    .padding(.top, 5)
                    .padding(.trailing, 92)
                }

                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Group {
                            GameText("\(status.def) + \(status.def2)")
                            GameText("\(status.mdef) + \(status.mdef2)")
                            GameText("\(status.flee) + \(status.flee2)")
                            GameText("\(status.aspd)")
                            GameText("\(status.statusPoint)")
                        }
                        .frame(height: 14)
                    }
                    .padding(.top, 5)
                    .padding(.trailing, 5)
                }
            }
            .frame(height: 123)
        }
        .frame(width: 280)
    }
}

#Preview {
    StatusView(status: CharacterStatus())
        .padding()
        .environment(GameSession())
}
