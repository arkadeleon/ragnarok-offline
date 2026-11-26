//
//  EffectViewerEffectListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import SwiftUI

struct EffectViewerEffectListView: View {
    var effects: [EffectViewerEffect]
    @Binding var selection: EffectViewerEffect?

    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var filteredEffects: [EffectViewerEffect]
    @State private var hasScrolledToSelection = false

    var body: some View {
        ScrollViewReader { proxy in
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
                    .id(effect.id)
                }
            }
            .listStyle(.plain)
            .onAppear {
                scrollToSelectionIfNeeded(using: proxy)
            }
            .onChange(of: filteredEffects) { _, _ in
                scrollToSelectionIfNeeded(using: proxy)
            }
        }
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

    init(
        effects: [EffectViewerEffect] = EffectViewerEffect.all,
        selection: Binding<EffectViewerEffect?>
    ) {
        self.effects = effects
        self._selection = selection
        self._filteredEffects = State(initialValue: effects)
    }

    private func scrollToSelectionIfNeeded(using proxy: ScrollViewProxy) {
        guard !hasScrolledToSelection,
              searchText.isEmpty,
              let selection,
              filteredEffects.contains(selection) else {
            return
        }

        hasScrolledToSelection = true
        proxy.scrollTo(selection.id, anchor: .center)
    }

    private func matchingEffects(_ searchText: String, in effects: [EffectViewerEffect]) async -> [EffectViewerEffect] {
        if searchText.isEmpty {
            return effects
        }

        if searchText.hasPrefix("#") {
            if let effectID = Int(searchText.dropFirst()),
               let effect = effects.first(where: { $0.id.rawValue == effectID }) {
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
