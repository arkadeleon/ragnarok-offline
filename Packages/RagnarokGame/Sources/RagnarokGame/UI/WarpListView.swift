//
//  WarpListView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/7.
//

import RagnarokModels
import SwiftUI

struct WarpListView: View {
    var warpList: WarpList

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var selectedIndex = 0

    var body: some View {
        GameWindow {
            VStack(spacing: 5) {
                Text(gameContext.messageStringTable.localizedMessageString(forID: 213))
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5)
                    .background(Color(#colorLiteral(red: 0.9372549020, green: 0.9568627451, blue: 0.9411764706, alpha: 1)))

                WarpListBox(mapNames: warpList.mapNames, selectedIndex: $selectedIndex)
            }
            .padding(5)
        } titleBar: {
            GameTitleBar {
                gameSession.cancelWarpPoint()
            }
        } bottomBar: {
            GameBottomBar {
                Button("OK") {
                    let mapName = warpList.mapNames[selectedIndex]
                    gameSession.selectWarpPoint(mapName: mapName)
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)

                Button("cancel") {
                    gameSession.cancelWarpPoint()
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
        }
        .frame(width: 280)
        .onChange(of: warpList.mapNames) {
            selectedIndex = 0
        }
    }
}

private struct WarpListBox: View {
    var mapNames: [String]
    @Binding var selectedIndex: Int

    @Environment(GameContext.self) private var gameContext

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<mapNames.count, id: \.self) { index in
                    Text(displayName(forMapName: mapNames[index]))
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

    private func displayName(forMapName mapName: String) -> String {
        let mapNameStem = mapName.split(separator: ".", maxSplits: 1).first.map(String.init) ?? mapName
        return gameContext.mapNameTable.localizedMapName(forMapName: mapNameStem) ?? mapNameStem
    }
}

#Preview {
    let warpList = WarpList(
        skillID: 26,
        mapNames: [
            "Random.gat",
            "prontera.gat",
        ]
    )

    WarpListView(warpList: warpList)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
        .environment(GameContext.testing)
}
