//
//  CharacterSimulatorView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/25.
//

import RagnarokResources
import SwiftUI

struct CharacterSimulatorView: View {
    @Environment(DatabaseModel.self) private var database
    @Environment(CharacterSimulator.self) private var characterSimulator

    var body: some View {
        AspectRatioAdaptiveView {
            VStack(spacing: 0) {
                CharacterRenderingView()
                    .frame(minHeight: 0, maxHeight: 300)

                Divider()

                CharacterConfigurationView()
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
        } wide: {
            HStack {
                CharacterRenderingView()
                    .frame(minWidth: 0, maxWidth: .infinity)

                CharacterConfigurationView()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.background.secondary)
                    .scrollContentBackground(.hidden)
            }
            .background(.background)
            .toolbarTitleDisplayMode(.automatic)
        }
        .navigationTitle(Text("Character Simulator", tableName: "CharacterSimulator"))
        .task {
            await database.fetchJobs()

            if !database.jobs.contains(where: { $0.id == characterSimulator.configuration.jobID }),
               let firstJob = database.jobs.first {
                characterSimulator.configuration.jobID = firstJob.id
            } else {
                await characterSimulator.renderSprite()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CharacterSimulatorView()
    }
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
    .environment(CharacterSimulator(resourceManager: .previewing))
}
