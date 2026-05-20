//
//  CharacterConfigurationView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/19.
//

import RagnarokConstants
import RagnarokResources
import RagnarokSprite
import SwiftUI

struct CharacterConfigurationView: View {
    @Environment(CharacterSimulator.self) private var characterSimulator

    var body: some View {
        @Bindable var characterSimulator = characterSimulator

        Form {
            Section {
                Picker(selection: $characterSimulator.configuration.jobID) {
                    ForEach(JobID.allCases, id: \.rawValue) { jobID in
                        Text(jobID.stringValue).tag(jobID)
                    }
                } label: {
                    Text("Job", tableName: "CharacterSimulator")
                }

                Picker(selection: $characterSimulator.configuration.gender) {
                    Text(Gender.female.localizedName).tag(Gender.female)
                    Text(Gender.male.localizedName).tag(Gender.male)
                } label: {
                    Text("Gender", tableName: "CharacterSimulator")
                }

                Picker(selection: $characterSimulator.configuration.hairStyle) {
                    // 1...42
                    ForEach(1..<43) { hairStyle in
                        Text(hairStyle.formatted()).tag(hairStyle)
                    }
                } label: {
                    Text("Hair Style", tableName: "CharacterSimulator")
                }

                Picker(selection: $characterSimulator.configuration.hairColor) {
                    Text("Default", tableName: "CharacterSimulator").tag(-1)

                    // 0...8
                    ForEach(0..<9) { hairColor in
                        Text(hairColor.formatted()).tag(hairColor)
                    }
                } label: {
                    Text("Hair Color", tableName: "CharacterSimulator")
                }

                Picker(selection: $characterSimulator.configuration.clothesColor) {
                    Text("Default", tableName: "CharacterSimulator").tag(-1)

                    // 0...7
                    ForEach(0..<8) { clothesColor in
                        Text(clothesColor.formatted()).tag(clothesColor)
                    }
                } label: {
                    Text("Clothes Color", tableName: "CharacterSimulator")
                }
            }

            Section {
                Picker(selection: $characterSimulator.configuration.weaponType) {
                    ForEach(WeaponType.allCases, id: \.rawValue) { weaponType in
                        Text(weaponType.localizedName).tag(weaponType)
                    }
                } label: {
                    Text(ItemType.weapon.localizedName)
                }

                Picker(selection: $characterSimulator.configuration.shield) {
                    Text("None", tableName: "CharacterSimulator").tag(0)

                    // 1...4
                    ForEach(1..<5) { shield in
                        Text(shield.formatted()).tag(shield)
                    }
                } label: {
                    Text(WeaponType.w_shield.localizedName)
                }

                CharacterEquipmentPicker(
                    LocalizedStringResource("Head Top", table: "CharacterSimulator"),
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.head_top)
                    },
                    selection: $characterSimulator.configuration.headTop
                )

                CharacterEquipmentPicker(
                    LocalizedStringResource("Head Mid", table: "CharacterSimulator"),
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.head_mid)
                    },
                    selection: $characterSimulator.configuration.headMid
                )

                CharacterEquipmentPicker(
                    LocalizedStringResource("Head Bottom", table: "CharacterSimulator"),
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.head_low)
                    },
                    selection: $characterSimulator.configuration.headBottom
                )

                CharacterEquipmentPicker(
                    LocalizedStringResource("Garment", table: "CharacterSimulator"),
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.garment) && item.view > 0
                    },
                    selection: $characterSimulator.configuration.garment
                )
            }

            Section {
                Picker(selection: $characterSimulator.configuration.actionType) {
                    ForEach(SpriteActionType.availableActionTypes(forJobID: characterSimulator.configuration.jobID.rawValue), id: \.rawValue) { actionType in
                        Text(actionType.description).tag(actionType)
                    }
                } label: {
                    Text("Action", tableName: "CharacterSimulator")
                }

                Picker(selection: $characterSimulator.configuration.headDirection) {
                    ForEach(SpriteHeadDirection.allCases, id: \.rawValue) { headDirection in
                        Text(headDirection.description).tag(headDirection)
                    }
                } label: {
                    Text("Head Direction", tableName: "CharacterSimulator")
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    CharacterConfigurationView()
        .environment(CharacterSimulator(resourceManager: .previewing))
        .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
