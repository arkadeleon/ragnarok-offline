//
//  CharacterConfigurationView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/19.
//

import RODatabase
import ROGenerated
import RORendering
import SwiftUI

struct CharacterConfigurationView: View {
    @Binding var configuration: CharacterConfiguration

    @State private var jobs: [Job] = []
    @State private var upperHeadgears: [Item] = []
    @State private var middleHeadgears: [Item] = []
    @State private var lowerHeadgears: [Item] = []

    @State private var color: Color = .blue

    var body: some View {
        Form {
            Picker("Job", selection: $configuration.jobID) {
                ForEach(jobs) { job in
                    Text(job.id.stringValue).tag(job.id)
                }
            }

            Picker("Gender", selection: $configuration.gender) {
                Text(Gender.female.stringValue).tag(Gender.female)
                Text(Gender.male.stringValue).tag(Gender.male)
            }

            Picker("Clothes Color", selection: $configuration.clothesColorID) {
                Text("Default").tag(Int?.none)

                // 0...7
                ForEach(0..<8) { clothesColorID in
                    Text(clothesColorID.formatted()).tag(clothesColorID)
                }
            }

            Picker("Hair Style", selection: $configuration.hairStyleID) {
                // 1...42
                ForEach(1..<43) { hairStyleID in
                    Text(hairStyleID.formatted()).tag(hairStyleID)
                }
            }

            Picker("Hair Color", selection: $configuration.hairColorID) {
                Text("Default").tag(Int?.none)

                // 0...8
                ForEach(0..<9) { hairColorID in
                    Text(hairColorID.formatted()).tag(hairColorID)
                }
            }

            Picker("Upper Headgear", selection: $configuration.upperHeadgear) {
                Text("None").tag(Item?.none)

                ForEach(upperHeadgears) { headgear in
                    Text(headgear.name).tag(headgear)
                }
            }

            Picker("Middle Headgear", selection: $configuration.middleHeadgear) {
                Text("None").tag(Item?.none)

                ForEach(middleHeadgears) { headgear in
                    Text(headgear.name).tag(headgear)
                }
            }

            Picker("Lower Headgear", selection: $configuration.lowerHeadgear) {
                Text("None").tag(Item?.none)

                ForEach(lowerHeadgears) { headgear in
                    Text(headgear.name).tag(headgear)
                }
            }

            Picker(selection: $configuration.weaponType) {
                ForEach(WeaponType.allCases, id: \.rawValue) { weaponType in
                    Text(weaponType.localizedStringResource).tag(weaponType)
                }
            } label: {
                Text(ItemType.weapon.localizedStringResource)
            }

            Picker(selection: $configuration.shieldID) {
                Text("None").tag(Int?.none)

                // 1...4
                ForEach(1..<5) { shieldID in
                    Text(shieldID.formatted()).tag(shieldID)
                }
            } label: {
                Text(WeaponType.w_shield.localizedStringResource)
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
            jobs = await JobDatabase.renewal.jobs()
        }
        .task {
            let equipItems = await ItemDatabase.renewal.equipItems()
            upperHeadgears = equipItems.filter({ $0.type == .armor && $0.locations.contains(.head_top) })
            middleHeadgears = equipItems.filter({ $0.type == .armor && $0.locations.contains(.head_mid) })
            lowerHeadgears = equipItems.filter({ $0.type == .armor && $0.locations.contains(.head_low) })
        }
    }
}

#Preview {
    @Previewable @State var configuration = CharacterConfiguration()

    CharacterConfigurationView(configuration: $configuration)
}
