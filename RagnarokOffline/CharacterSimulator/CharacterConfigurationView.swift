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

    var body: some View {
        Form {
            Picker("Job", selection: $configuration.jobID) {
                ForEach(jobs) { job in
                    Text(job.id.stringValue)
                        .tag(job.id)
                }
            }

            Picker("Gender", selection: $configuration.gender) {
                Text(Gender.female.stringValue)
                    .tag(Gender.female)
                Text(Gender.male.stringValue)
                    .tag(Gender.male)
            }

            Picker("Hair Style", selection: $configuration.hairStyleID) {
                ForEach(1..<43) { hairStyle in
                    Text(hairStyle.formatted())
                        .tag(hairStyle)
                }
            }

            Picker("Action", selection: $configuration.actionType) {
                ForEach(PlayerActionType.allCases, id: \.rawValue) { actionType in
                    Text(actionType.description)
                        .tag(actionType)
                }
            }

            Picker("Direction", selection: $configuration.direction) {
                ForEach(BodyDirection.allCases, id: \.rawValue) { direction in
                    Text(direction.description)
                        .tag(direction)
                }
            }

            Picker("Head Direction", selection: $configuration.headDirection) {
                ForEach(HeadDirection.allCases, id: \.rawValue) { headDirection in
                    Text(headDirection.description)
                        .tag(headDirection)
                }
            }
        }
        .task {
            jobs = await JobDatabase.renewal.jobs()
        }
    }
}

#Preview {
    @Previewable @State var configuration = CharacterConfiguration()

    CharacterConfigurationView(configuration: $configuration)
}
