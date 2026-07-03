//
//  EffectViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/3/14.
//

import RagnarokResources
import SwiftUI

struct EffectViewer: View {
    var resourceManager: ResourceManager

    @Namespace private var effectNamespace

    @State private var isPicking = false
    @State private var selectedEffect: EffectViewerEffect?
    @State private var replayToken = 0

    var body: some View {
        ZStack {
            if let selectedEffect {
                EffectViewerEffectRenderingView(effectID: selectedEffect.effectID, resourceManager: resourceManager) {
                    replayToken += 1
                }
                .id("\(selectedEffect.id)-\(replayToken)")
            } else {
                ContentUnavailableView {
                    Label {
                        Text("No Effect Selected", tableName: "EffectViewer")
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                } description: {
                    Text("Choose an effect to view", tableName: "EffectViewer")
                } actions: {
                    Button {
                        isPicking = true
                    } label: {
                        Label {
                            Text("Choose an Effect", tableName: "EffectViewer")
                        } icon: {
                            Image(systemName: "sparkles")
                        }
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    }
                    .adaptiveProminentButtonStyle()
                    .matchedTransitionSource(id: "effect", in: effectNamespace)
                }
            }
        }
        .navigationTitle(Text("Effect Viewer", tableName: "EffectViewer"))
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            if let selectedEffect {
                ToolbarItem {
                    Button {
                        isPicking = true
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text(selectedEffect.displayName)
                        }
                    }
                    .matchedTransitionSource(id: "effect", in: effectNamespace)
                }
            }
        }
        .sheet(isPresented: $isPicking) {
            NavigationStack {
                EffectViewerEffectListView(selection: $selectedEffect)
            }
            .presentationSizing(.form)
            .adaptiveNavigationTransition(sourceID: "effect", in: effectNamespace)
        }
    }
}
