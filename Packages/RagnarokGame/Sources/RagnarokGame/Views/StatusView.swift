//
//  StatusView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/8.
//

import RagnarokConstants
import RagnarokNetwork
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
                        Text(verbatim: "\(status.str)")
                        Text(verbatim: "\(status.agi)")
                        Text(verbatim: "\(status.vit)")
                        Text(verbatim: "\(status.int)")
                        Text(verbatim: "\(status.dex)")
                        Text(verbatim: "\(status.luk)")
                    }
                    .gameText()
                    .frame(height: 14)
                }
                .offset(x: 37, y: 6)

                VStack(spacing: 2) {
                    Group {
                        Text(verbatim: "+\(status.str2)")
                        Text(verbatim: "+\(status.agi2)")
                        Text(verbatim: "+\(status.vit2)")
                        Text(verbatim: "+\(status.int2)")
                        Text(verbatim: "+\(status.dex2)")
                        Text(verbatim: "+\(status.luk2)")
                    }
                    .gameText()
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
                        Text(verbatim: "\(status.str3)")
                        Text(verbatim: "\(status.agi3)")
                        Text(verbatim: "\(status.vit3)")
                        Text(verbatim: "\(status.int3)")
                        Text(verbatim: "\(status.dex3)")
                        Text(verbatim: "\(status.luk3)")
                    }
                    .gameText()
                    .frame(width: 14, height: 14, alignment: .trailing)
                }
                .offset(x: 87, y: 6)

                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Group {
                            Text(verbatim: "\(status.atk) + \(status.atk2)")
                            Text(verbatim: "\(status.matk) + \(status.matk2)")
                            Text(verbatim: "\(status.hit)")
                            Text(verbatim: "\(status.critical)")
                        }
                        .gameText()
                        .frame(height: 14)
                    }
                    .padding(.top, 5)
                    .padding(.trailing, 92)
                }

                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Group {
                            Text(verbatim: "\(status.def) + \(status.def2)")
                            Text(verbatim: "\(status.mdef) + \(status.mdef2)")
                            Text(verbatim: "\(status.flee) + \(status.flee2)")
                            Text(verbatim: "\(status.aspd)")
                            Text(verbatim: "\(status.statusPoint)")
                        }
                        .gameText()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
