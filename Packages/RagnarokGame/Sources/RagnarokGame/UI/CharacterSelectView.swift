//
//  CharacterSelectView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/10.
//

import RagnarokConstants
import RagnarokLocalization
import RagnarokModels
import RagnarokSprite
import SwiftUI

struct CharacterSelectView: View {
    var characters: [CharacterInfo]

    @Environment(GameSession.self) private var gameSession

    @State private var characterAnimationsBySlot: [Int : SpriteRenderer.Animation] = [:]
    @State private var showingDeleteConfirmation = false
    @State private var showingCancelConfirmation = false

    private let slotsPerPage = 3

    private var charactersBySlot: [Int: CharacterInfo] {
        Dictionary(uniqueKeysWithValues: characters.map { ($0.charNum, $0) })
    }

    private var selectedCharacter: CharacterInfo? {
        charactersBySlot[gameSession.selectedCharacterSlot]
    }

    private var currentPage: Int {
        gameSession.selectedCharacterSlot / slotsPerPage
    }

    private var totalPages: Int {
        max(1, (gameSession.maxCharacterSlots + slotsPerPage - 1) / slotsPerPage)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("login_interface/win_select.bmp")

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        let newSlot = (gameSession.selectedCharacterSlot - 1 + gameSession.maxCharacterSlots) % gameSession.maxCharacterSlots
                        gameSession.selectedCharacterSlot = newSlot
                    } label: {
                        GameImage("scroll1left.bmp")
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    HStack(spacing: 24) {
                        ForEach(0..<slotsPerPage, id: \.self) { position in
                            let slot = currentPage * slotsPerPage + position
                            if slot < gameSession.maxCharacterSlots {
                                Button {
                                    gameSession.selectedCharacterSlot = slot
                                } label: {
                                    ZStack {
                                        if gameSession.selectedCharacterSlot == slot {
                                            GameImage("login_interface/box_select.bmp")
                                        }
                                        if let characterAnimation = characterAnimationsBySlot[slot],
                                           let firstFrame = characterAnimation.firstFrame {
                                            Image(decorative: firstFrame, scale: 2)
                                                .offset(y: 10)
                                        }
                                    }
                                    .frame(width: 139, height: 144)
                                }
                                .buttonStyle(.borderless)
                            } else {
                                Color.clear
                                    .frame(width: 139, height: 144)
                            }
                        }
                    }

                    Spacer()

                    Button {
                        let newSlot = (gameSession.selectedCharacterSlot + 1) % gameSession.maxCharacterSlots
                        gameSession.selectedCharacterSlot = newSlot
                    } label: {
                        GameImage("scroll1right.bmp")
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.borderless)
                }

                Text("\(currentPage + 1) / \(totalPages)")
                    .font(.game())
                    .frame(maxWidth: .infinity)
                    .padding(.top, 1)
            }
            .frame(width: 576)
            .offset(y: 40)

            if let selectedCharacter {
                VStack(spacing: 1) {
                    Group {
                        Text(selectedCharacter.name)
                        Text(jobName(for: selectedCharacter))
                        Text(selectedCharacter.level.formatted())
                        Text(selectedCharacter.exp.formatted())
                        Text(selectedCharacter.hp.formatted())
                        Text(selectedCharacter.sp.formatted())
                        Text(mapName(for: selectedCharacter))
                    }
                    .gameText()
                    .frame(width: 95, height: 15)
                }
                .offset(x: 65, y: 204)

                VStack(spacing: 1) {
                    Group {
                        Text(selectedCharacter.str.formatted())
                        Text(selectedCharacter.agi.formatted())
                        Text(selectedCharacter.vit.formatted())
                        Text(selectedCharacter.int.formatted())
                        Text(selectedCharacter.dex.formatted())
                        Text(selectedCharacter.luk.formatted())
                    }
                    .gameText()
                    .frame(width: 95, height: 15)
                }
                .offset(x: 209, y: 204)
            }
        }
        .frame(width: 576, height: 342)
        .overlay(alignment: .bottomLeading) {
            HStack(spacing: 3) {
                if selectedCharacter != nil {
                    Button("del") {
                        showingDeleteConfirmation = true
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 3) {
                if selectedCharacter == nil {
                    Button("make") {
                        gameSession.makeCharacter(slot: gameSession.selectedCharacterSlot)
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                }

                if selectedCharacter != nil {
                    Button("OK") {
                        gameSession.loginAudioPlayer.playButtonSound()
                        gameSession.selectCharacter(slot: gameSession.selectedCharacterSlot)
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                }

                Button("cancel") {
                    showingCancelConfirmation = true
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
        }
        .overlay(alignment: .center) {
            if showingDeleteConfirmation {
                MessageBoxView(gameSession.messageStringTable.localizedMessageString(forID: 19))
                    .overlay(alignment: .bottomTrailing) {
                        HStack(spacing: 3) {
                            Button("OK") {
                                if let charID = selectedCharacter?.charID {
                                    gameSession.deleteCharacter(charID: charID)
                                }
                                showingDeleteConfirmation = false
                            }
                            .buttonStyle(.game)
                            .frame(width: 42, height: 20)

                            Button("cancel") {
                                showingDeleteConfirmation = false
                            }
                            .buttonStyle(.game)
                            .frame(width: 42, height: 20)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                    }
            } else if showingCancelConfirmation {
                MessageBoxView(gameSession.messageStringTable.localizedMessageString(forID: 17))
                    .overlay(alignment: .bottomTrailing) {
                        HStack(spacing: 3) {
                            Button("OK") {
                                gameSession.exitCurrentPhase()
                            }
                            .buttonStyle(.game)
                            .frame(width: 42, height: 20)

                            Button("cancel") {
                                showingCancelConfirmation = false
                            }
                            .buttonStyle(.game)
                            .frame(width: 42, height: 20)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                    }
            }
        }
        .task(id: currentPage) {
            await loadCharacterAnimationsForCurrentPage()
        }
        .task(id: characters.map(\.charNum).sorted()) {
            await loadCharacterAnimationsForCurrentPage()
        }
        .onChange(of: characters.map(\.charNum).sorted()) { oldValue, newValue in
            let removedSlots = Set(oldValue).subtracting(newValue)
            for slot in removedSlots {
                characterAnimationsBySlot.removeValue(forKey: slot)
            }
        }
    }

    private func jobName(for character: CharacterInfo) -> String {
        guard let jobID = JobID(rawValue: character.job),
              let jobName = gameSession.messageStringTable.localizedJobName(for: jobID) else {
            return ""
        }
        return jobName
    }

    private func mapName(for character: CharacterInfo) -> String {
        guard !character.mapName.isEmpty else {
            return ""
        }
        guard let mapName = gameSession.mapNameTable.localizedMapName(forMapName: character.mapName) else {
            return character.mapName
        }
        return mapName
    }

    private func loadCharacterAnimationsForCurrentPage() async {
        let startSlot = currentPage * slotsPerPage
        let endSlot = min(startSlot + slotsPerPage, gameSession.maxCharacterSlots)
        for slot in startSlot..<endSlot {
            guard charactersBySlot[slot] != nil, characterAnimationsBySlot[slot] == nil else {
                continue
            }
            if let characterAnimation = await gameSession.characterAnimation(forSlot: slot) {
                characterAnimationsBySlot[slot] = characterAnimation
            }
        }
    }
}

#Preview {
    let character = {
        var character = CharacterInfo()
        character.name = "Leon"
        character.str = 1
        character.agi = 1
        character.vit = 1
        character.int = 1
        character.dex = 1
        character.luk = 1
        return character
    }()

    CharacterSelectView(characters: [character])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
