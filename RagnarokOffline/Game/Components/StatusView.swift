//
//  StatusView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/8.
//

import ROConstants
import ROGame
import SwiftUI

struct StatusView: View {
    var status: Player.Status
    var onIncrementStatusProperty: (StatusProperty) -> Void

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
                            onIncrementStatusProperty(.str)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            onIncrementStatusProperty(.agi)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            onIncrementStatusProperty(.vit)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            onIncrementStatusProperty(.int)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            onIncrementStatusProperty(.dex)
                        }
                        GameButton("basic_interface/arw_right.bmp") {
                            onIncrementStatusProperty(.luk)
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

                VStack(spacing: 2) {
                    Group {
                        GameText("\(status.atk) + \(status.atk2)")
                        GameText("\(status.matk) + \(status.matk2)")
                        GameText("\(status.hit)")
                        GameText("\(status.critical)")
                    }
                    .frame(width: 54, height: 14, alignment: .trailing)
                }
                .offset(x: 134, y: 5)

                VStack(spacing: 2) {
                    Group {
                        GameText("\(status.def) + \(status.def2)")
                        GameText("\(status.mdef) + \(status.mdef2)")
                        GameText("\(status.flee) + \(status.flee2)")
                        GameText("\(status.aspd)")
                        GameText("\(status.statusPoint)")
                    }
                    .frame(width: 54, height: 14, alignment: .trailing)
                }
                .offset(x: 221, y: 5)
            }
            .frame(height: 123)
        }
        .frame(width: 280)
    }

    init(status: Player.Status, onIncrementStatusProperty: @escaping (StatusProperty) -> Void) {
        self.status = status
        self.onIncrementStatusProperty = onIncrementStatusProperty
    }
}

#Preview {
    StatusView(status: Player.Status()) { _ in
    }
    .padding()
}
