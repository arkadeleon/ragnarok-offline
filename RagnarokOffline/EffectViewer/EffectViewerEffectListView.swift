//
//  EffectViewerEffectListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import SwiftUI

struct EffectViewerEffectListView: View {
    var effects: [EffectViewerEffect] = EffectViewerEffect.all
    @Binding var selection: EffectViewerEffect?

    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var filteredEffects: [EffectViewerEffect] = []

    var body: some View {
        List {
            ForEach(filteredEffects) { effect in
                Button {
                    selection = effect
                    dismiss()
                } label: {
                    HStack {
                        Text(effect.displayName)

                        Spacer()

                        if selection == effect {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.link)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Text("Effect", tableName: "EffectViewer"))
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarCloseButton {
                dismiss()
            }
        }
        .adaptiveSearch(text: $searchText)
        .task(id: "\(effects.count)-\(searchText)") {
            filteredEffects = await matchingEffects(searchText, in: effects)
        }
    }

    private func matchingEffects(_ searchText: String, in effects: [EffectViewerEffect]) async -> [EffectViewerEffect] {
        if searchText.isEmpty {
            return effects
        }

        if searchText.hasPrefix("#") {
            if let effectID = Int(searchText.dropFirst()),
               let effect = effects.first(where: { $0.id == effectID }) {
                return [effect]
            } else {
                return []
            }
        }

        let filteredEffects = effects.filter { effect in
            effect.displayName.localizedStandardContains(searchText)
        }
        return filteredEffects
    }
}

#Preview {
    @Previewable @State var selection: EffectViewerEffect? = nil

    NavigationStack {
        EffectViewerEffectListView(selection: $selection)
    }
}
