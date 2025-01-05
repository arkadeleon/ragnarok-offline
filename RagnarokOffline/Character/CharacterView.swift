//
//  CharacterView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/25.
//

import RealityKit
import SwiftUI

struct CharacterView: View {
    @State private var action = 0

    var body: some View {
        RealityView { content in
            if let entity = try? await Entity.loadJob(jobID: .novice) {
                entity.name = "character"
                entity.position = [0, 0, 0]
                content.add(entity)
            }
        } update: { content in
            if let entity = content.entities.first {
                entity.runAction(action)
                entity.findEntity(named: "head")?.runAction(action)

                let transform = Transform(translation: [0, -1, 0])
                entity.move(to: transform, relativeTo: nil, duration: 30, timingFunction: .linear)
            }
        } placeholder: {
            ProgressView()
        }
        .toolbar {
            Picker(selection: $action) {
                ForEach(0..<24) { i in
                    Text(verbatim: "\(i)")
                        .tag(i)
                }
            } label: {
                Image(systemName: "figure.run.circle")
            }
        }
    }
}
