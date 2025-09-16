//
//  CharacterConfigurationView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/19.
//

import Constants
import SpriteRendering
import SwiftUI

struct CharacterConfigurationView: View {
    @Environment(CharacterSimulator.self) private var characterSimulator

    var body: some View {
        @Bindable var characterSimulator = characterSimulator

        Form {
            Section {
                Picker("Job", selection: $characterSimulator.configuration.jobID) {
                    ForEach(JobID.allCases, id: \.rawValue) { jobID in
                        Text(jobID.stringValue).tag(jobID)
                    }
                }

                Picker("Gender", selection: $characterSimulator.configuration.gender) {
                    Text(Gender.female.localizedName).tag(Gender.female)
                    Text(Gender.male.localizedName).tag(Gender.male)
                }

                Picker("Hair Style", selection: $characterSimulator.configuration.hairStyle) {
                    // 1...42
                    ForEach(1..<43) { hairStyle in
                        Text(hairStyle.formatted()).tag(hairStyle)
                    }
                }

                Picker("Hair Color", selection: $characterSimulator.configuration.hairColor) {
                    Text("Default").tag(-1)

                    // 0...8
                    ForEach(0..<9) { hairColor in
                        Text(hairColor.formatted()).tag(hairColor)
                    }
                }

                Picker("Clothes Color", selection: $characterSimulator.configuration.clothesColor) {
                    Text("Default").tag(-1)

                    // 0...7
                    ForEach(0..<8) { clothesColor in
                        Text(clothesColor.formatted()).tag(clothesColor)
                    }
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
                    Text("None").tag(0)

                    // 1...4
                    ForEach(1..<5) { shield in
                        Text(shield.formatted()).tag(shield)
                    }
                } label: {
                    Text(WeaponType.w_shield.localizedName)
                }

                CharacterEquipmentPicker(
                    "Head Top",
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.head_top)
                    },
                    selection: $characterSimulator.configuration.headTop
                )

                CharacterEquipmentPicker(
                    "Head Mid",
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.head_mid)
                    },
                    selection: $characterSimulator.configuration.headMid
                )

                CharacterEquipmentPicker(
                    "Head Bottom",
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.head_low)
                    },
                    selection: $characterSimulator.configuration.headBottom
                )

                CharacterEquipmentPicker(
                    "Garment",
                    predicate: { item in
                        item.type == .armor && item.locations.contains(.garment) && item.view > 0
                    },
                    selection: $characterSimulator.configuration.garment
                )
            }

            Section {
                Picker("Action", selection: $characterSimulator.configuration.actionType) {
                    ForEach(ComposedSprite.ActionType.availableActionTypes(forJobID: characterSimulator.configuration.jobID.rawValue), id: \.rawValue) { actionType in
                        Text(actionType.description).tag(actionType)
                    }
                }

                Picker("Head Direction", selection: $characterSimulator.configuration.headDirection) {
                    ForEach(ComposedSprite.HeadDirection.allCases, id: \.rawValue) { headDirection in
                        Text(headDirection.description).tag(headDirection)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    CharacterConfigurationView()
        .environment(CharacterSimulator())
        .environment(DatabaseModel(mode: .renewal))
}
