//
//  CharacterConfigurationView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/19.
//

import ROConstants
import RORendering
import SwiftUI

struct CharacterConfigurationView: View {
    @Environment(AppModel.self) private var appModel

    @State private var headTopItems: [ItemModel] = []
    @State private var headMidItems: [ItemModel] = []
    @State private var headBottomItems: [ItemModel] = []
    @State private var garmentItems: [ItemModel] = []

    var body: some View {
        @Bindable var characterSimulator = appModel.characterSimulator

        Form {
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

            Picker(selection: $characterSimulator.configuration.weaponType) {
                ForEach(WeaponType.allCases, id: \.rawValue) { weaponType in
                    Text(weaponType.localizedStringResource).tag(weaponType)
                }
            } label: {
                Text(ItemType.weapon.localizedStringResource)
            }

            Picker(selection: $characterSimulator.configuration.shield) {
                Text("None").tag(0)

                // 1...4
                ForEach(1..<5) { shield in
                    Text(shield.formatted()).tag(shield)
                }
            } label: {
                Text(WeaponType.w_shield.localizedStringResource)
            }

            Picker("Head Top", selection: $characterSimulator.configuration.headTop) {
                Text("None").tag(ItemModel?.none)

                ForEach(headTopItems) { item in
                    Text(item.displayName).tag(item)
                }
            }

            Picker("Head Mid", selection: $characterSimulator.configuration.headMid) {
                Text("None").tag(ItemModel?.none)

                ForEach(headMidItems) { item in
                    Text(item.displayName).tag(item)
                }
            }

            Picker("Head Bottom", selection: $characterSimulator.configuration.headBottom) {
                Text("None").tag(ItemModel?.none)

                ForEach(headBottomItems) { item in
                    Text(item.displayName).tag(item)
                }
            }

            Picker(selection: $characterSimulator.configuration.garment) {
                Text("None").tag(ItemModel?.none)

                ForEach(garmentItems) { item in
                    Text(item.displayName).tag(item)
                }
            } label: {
                Text(verbatim: "Garment")
            }

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
        .formStyle(.grouped)
        .task {
            await appModel.itemDatabase.fetchRecords()

            let items = appModel.itemDatabase.records
            headTopItems = items.filter({ $0.type == .armor && $0.locations.contains(.head_top) })
            headMidItems = items.filter({ $0.type == .armor && $0.locations.contains(.head_mid) })
            headBottomItems = items.filter({ $0.type == .armor && $0.locations.contains(.head_low) })
            garmentItems = items.filter({ $0.type == .armor && $0.locations.contains(.garment) && $0.view > 0 })
        }
    }
}

#Preview {
    CharacterConfigurationView()
        .environment(AppModel())
}
