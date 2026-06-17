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
    @Environment(\.messageStringTable) private var messageStringTable

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

    var body: some View {
        GameWindow {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    CharacterSlotPanel(characterAnimations: characterAnimationsBySlot)
                        .padding(.top, 26)

                    CharacterInfoPanel(character: selectedCharacter)
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                }

                VStack(alignment: .trailing, spacing: -6) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("Select")
                            .font(.system(size: 36, weight: .black))
                            .italic()
                        Text("Your")
                            .font(.system(size: 20, weight: .bold))
                            .italic()
                    }
                    Text("Characters")
                        .font(.system(size: 32, weight: .black))
                        .italic()
                }
                .foregroundStyle(Color(red: 0.42, green: 0.51, blue: 0.66, opacity: 0.88))
                .padding(.trailing, 10)
                .padding(.bottom, 10)
            }
            .background {
                GameVineBackground()
            }
        } bottomBar: {
            GameBottomBar {
                if selectedCharacter != nil {
                    Button("del") {
                        showingDeleteConfirmation = true
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                }

                Spacer()

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
        }
        .frame(width: 576)
        .overlay(alignment: .center) {
            if showingDeleteConfirmation {
                MessageBoxView(messageStringTable.localizedMessageString(forID: 19)) {
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
            } else if showingCancelConfirmation {
                MessageBoxView(messageStringTable.localizedMessageString(forID: 17)) {
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

private struct CharacterSlotPanel: View {
    var characterAnimations: [Int : SpriteRenderer.Animation]

    @Environment(GameSession.self) private var gameSession

    private let slotsPerPage = 3

    private var currentPage: Int {
        gameSession.selectedCharacterSlot / slotsPerPage
    }

    private var totalPages: Int {
        max(1, (gameSession.maxCharacterSlots + slotsPerPage - 1) / slotsPerPage)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button {
                    let newSlot = (gameSession.selectedCharacterSlot - 1 + gameSession.maxCharacterSlots) % gameSession.maxCharacterSlots
                    gameSession.selectedCharacterSlot = newSlot
                } label: {
                    GameLeftArrow()
                        .fill(Color(#colorLiteral(red: 0.6666666667, green: 0.7294117647, blue: 0.8862745098, alpha: 1)))
                        .stroke(Color(#colorLiteral(red: 0.4588235294, green: 0.5490196078, blue: 0.8196078431, alpha: 1)), lineWidth: 1)
                        .frame(width: 10, height: 13)
                        .padding()
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 32) {
                    ForEach(0..<slotsPerPage, id: \.self) { position in
                        let slot = currentPage * slotsPerPage + position
                        if slot < gameSession.maxCharacterSlots {
                            Button {
                                gameSession.selectedCharacterSlot = slot
                            } label: {
                                ZStack {
                                    if gameSession.selectedCharacterSlot == slot {
                                        CharacterSlotSelectionFrame()
                                    } else {
                                        Rectangle()
                                            .strokeBorder(Color.gameBoxBorder, lineWidth: 2)
                                    }

                                    Ellipse()
                                        .fill(Color(#colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1)))
                                        .blur(radius: 4)
                                        .frame(width: 38, height: 24)
                                        .offset(y: 48)

                                    if let characterAnimation = characterAnimations[slot],
                                       let firstFrame = characterAnimation.firstFrame {
                                        Image(decorative: firstFrame, scale: 2)
                                            .offset(y: 10)
                                    }
                                }
                                .frame(width: 131, height: 138)
                            }
                            .buttonStyle(.borderless)
                        } else {
                            Color.clear
                                .frame(width: 131, height: 138)
                        }
                    }
                }

                Spacer()

                Button {
                    let newSlot = (gameSession.selectedCharacterSlot + 1) % gameSession.maxCharacterSlots
                    gameSession.selectedCharacterSlot = newSlot
                } label: {
                    GameRightArrow()
                        .fill(Color(#colorLiteral(red: 0.6666666667, green: 0.7294117647, blue: 0.8862745098, alpha: 1)))
                        .stroke(Color(#colorLiteral(red: 0.4588235294, green: 0.5490196078, blue: 0.8196078431, alpha: 1)), lineWidth: 1)
                        .frame(width: 10, height: 13)
                        .padding()
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Text("\(currentPage + 1) / \(totalPages)")
                .font(.game())
                .frame(height: 23)
        }
    }
}

private struct CharacterSlotSelectionFrame: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .strokeBorder(Color(#colorLiteral(red: 0.4823529412, green: 0.5686274510, blue: 0.7725490196, alpha: 1)), lineWidth: 4)

            UnevenRoundedRectangle(bottomTrailingRadius: 5)
                .fill(Color(#colorLiteral(red: 0.4823529412, green: 0.5686274510, blue: 0.7725490196, alpha: 1)))
                .offset(x: 4, y: 4)
                .frame(width: 67, height: 18)

            Text(verbatim: "Select")
                .font(.game(size: 13, weight: .black))
                .foregroundStyle(Color.white)
                .padding(.leading, 8)
                .padding(.top, 4)
        }
    }
}

private struct CharacterInfoPanel: View {
    var character: CharacterInfo?

    @Environment(\.mapNameTable) private var mapNameTable

    var body: some View {
        HStack(alignment: .top, spacing: 1) {
            VStack(alignment: .leading, spacing: 1) {
                CharacterInfoRow("Name", value: character?.name ?? "")
                CharacterInfoRow("Job", value: character.map { jobName(for: $0) } ?? "")
                CharacterInfoRow("Lv.", value: character?.level.formatted() ?? "")
                CharacterInfoRow("EXP", value: character?.exp.formatted() ?? "")
                CharacterInfoRow("HP", value: character?.hp.formatted() ?? "")
                CharacterInfoRow("SP", value: character?.sp.formatted() ?? "")
                CharacterInfoRow("Map", value: character.map { mapName(for: $0) } ?? "")
            }

            VStack(alignment: .leading, spacing: 1) {
                CharacterInfoRow("STR", value: character?.str.formatted() ?? "")
                CharacterInfoRow("AGI", value: character?.agi.formatted() ?? "")
                CharacterInfoRow("VIT", value: character?.vit.formatted() ?? "")
                CharacterInfoRow("INT", value: character?.int.formatted() ?? "")
                CharacterInfoRow("DEX", value: character?.dex.formatted() ?? "")
                CharacterInfoRow("LUK", value: character?.luk.formatted() ?? "")
            }
        }
    }

    private func jobName(for character: CharacterInfo) -> String {
        guard let jobID = JobID(rawValue: character.job),
              let name = jobID.localizedName else {
            return ""
        }
        return String(localized: name)
    }

    private func mapName(for character: CharacterInfo) -> String {
        guard !character.mapName.isEmpty else {
            return ""
        }
        guard let mapName = mapNameTable.localizedMapName(forMapName: character.mapName) else {
            return character.mapName
        }
        return mapName
    }
}

private struct CharacterInfoRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: label)
                .font(.game(weight: .bold))
                .foregroundStyle(Color.gameProminentLabel)
                .padding(.leading, 3)
                .frame(width: 48, height: 15, alignment: .leading)
                .background(Color(#colorLiteral(red: 0.773, green: 0.812, blue: 0.890, alpha: 1)))
            Text(verbatim: value)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .frame(width: 95, height: 15, alignment: .center)
                .background(Color(#colorLiteral(red: 0.914, green: 0.937, blue: 0.969, alpha: 1)))
        }
    }

    init(_ label: String, value: String) {
        self.label = label
        self.value = value
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
