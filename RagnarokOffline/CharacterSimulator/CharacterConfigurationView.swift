//
//  CharacterConfigurationView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/19.
//

import ROConstants
import RODatabase
import RORendering
import SwiftUI

struct CharacterConfigurationView: View {
    @Binding var configuration: CharacterConfiguration

    @State private var headTopItems: [Item] = []
    @State private var headMidItems: [Item] = []
    @State private var headBottomItems: [Item] = []

    var body: some View {
        Form {
            Picker("Job", selection: $configuration.jobID) {
                ForEach(JobID.allCases, id: \.rawValue) { jobID in
                    Text(jobID.stringValue).tag(jobID)
                }
            }

            Picker("Gender", selection: $configuration.gender) {
                Text(Gender.female.stringValue).tag(Gender.female)
                Text(Gender.male.stringValue).tag(Gender.male)
            }

            Picker("Hair Style", selection: $configuration.hairStyle) {
                // 1...42
                ForEach(1..<43) { hairStyle in
                    Text(hairStyle.formatted()).tag(hairStyle)
                }
            }

            Picker("Hair Color", selection: $configuration.hairColor) {
                Text("Default").tag(-1)

                // 0...8
                ForEach(0..<9) { hairColor in
                    Text(hairColor.formatted()).tag(hairColor)
                }
            }

            Picker("Clothes Color", selection: $configuration.clothesColor) {
                Text("Default").tag(-1)

                // 0...7
                ForEach(0..<8) { clothesColor in
                    Text(clothesColor.formatted()).tag(clothesColor)
                }
            }

            Picker(selection: $configuration.weaponType) {
                ForEach(WeaponType.allCases, id: \.rawValue) { weaponType in
                    Text(weaponType.localizedStringResource).tag(weaponType)
                }
            } label: {
                Text(ItemType.weapon.localizedStringResource)
            }

            Picker(selection: $configuration.shield) {
                Text("None").tag(0)

                // 1...4
                ForEach(1..<5) { shield in
                    Text(shield.formatted()).tag(shield)
                }
            } label: {
                Text(WeaponType.w_shield.localizedStringResource)
            }

            Picker("Head Top", selection: $configuration.headTop) {
                Text("None").tag(Item?.none)

                ForEach(headTopItems) { item in
                    Text(item.name).tag(item)
                }
            }

            Picker("Head Mid", selection: $configuration.headMid) {
                Text("None").tag(Item?.none)

                ForEach(headMidItems) { item in
                    Text(item.name).tag(item)
                }
            }

            Picker("Head Bottom", selection: $configuration.headBottom) {
                Text("None").tag(Item?.none)

                ForEach(headBottomItems) { item in
                    Text(item.name).tag(item)
                }
            }

            Picker("Action", selection: $configuration.actionType) {
                ForEach(PlayerActionType.allCases, id: \.rawValue) { actionType in
                    Text(actionType.description).tag(actionType)
                }
            }

            Picker("Direction", selection: $configuration.direction) {
                ForEach(BodyDirection.allCases, id: \.rawValue) { direction in
                    Text(direction.description).tag(direction)
                }
            }

            Picker("Head Direction", selection: $configuration.headDirection) {
                ForEach(HeadDirection.allCases, id: \.rawValue) { headDirection in
                    Text(headDirection.description).tag(headDirection)
                }
            }
        }
        .formStyle(.grouped)
        .task {
            let equipItems = await ItemDatabase.renewal.equipItems()
            headTopItems = equipItems.filter({ $0.type == .armor && $0.locations.contains(.head_top) })
            headMidItems = equipItems.filter({ $0.type == .armor && $0.locations.contains(.head_mid) })
            headBottomItems = equipItems.filter({ $0.type == .armor && $0.locations.contains(.head_low) })
        }
    }
}

#Preview {
    @Previewable @State var configuration = CharacterConfiguration()

    CharacterConfigurationView(configuration: $configuration)
}
