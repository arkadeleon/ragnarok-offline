//
//  EffectViewerEffectListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import SwiftUI

struct EffectViewerEffectListView: View {
    @Binding var selection: EffectViewerEffect?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(EffectViewerEffect.all) { effect in
                Button {
                    selection = effect
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(effect.displayName)
                            Text(effect.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

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
            ToolbarDoneButton {
                dismiss()
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: EffectViewerEffect? = nil

    NavigationStack {
        EffectViewerEffectListView(selection: $selection)
    }
}
