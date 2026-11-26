//
//  EffectViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/3/14.
//

import Metal
import RagnarokEffects
import RagnarokRendering
import RagnarokResources
import SwiftUI

struct EffectViewer: View {
    var resourceManager: ResourceManager

    @Namespace private var effectNamespace

    @State private var isPicking = false
    @State private var selectedEffect: EffectViewerEffect?
    @State private var ez2strEffectCatalog: EZ2STREffectCatalog?
    @State private var renderer: EffectViewerEffectRenderer?
    @State private var loadError: (any Error)?

    var body: some View {
        let effects = EffectViewerEffect.all(ez2strEffectCatalog: ez2strEffectCatalog)

        VStack(spacing: 12) {
            ZStack {
                EffectViewerStageBackground()

                if let renderer {
                    MetalViewContainer(renderer: renderer)
                        .id(ObjectIdentifier(renderer))
                } else if let loadError {
                    Text(loadError.localizedDescription)
                        .frame(maxWidth: 240)
                        .multilineTextAlignment(.center)
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
            .overlay(alignment: .topLeading) {
                if let selectedEffect {
                    Button {
                        isPicking = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                            Text(selectedEffect.displayName)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .adaptiveStageCapsuleBackground()
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: "effect", in: effectNamespace)
                    .padding(12)
                }
            }
            .environment(\.colorScheme, .dark)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            EffectViewerPlaybackControlsView(renderer: renderer)
        }
        .padding()
        .navigationTitle(Text("Effect Viewer", tableName: "EffectViewer"))
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPicking) {
            NavigationStack {
                EffectViewerEffectListView(
                    effects: effects,
                    selection: $selectedEffect
                )
            }
            .presentationSizing(.form)
            .adaptiveNavigationTransition(sourceID: "effect", in: effectNamespace)
        }
        .task {
            ez2strEffectCatalog = await EZ2STREffectCatalog.load(from: resourceManager)
        }
        .task(id: selectedEffect) {
            let previousIsLooping = renderer?.isLooping ?? true
            let previousPlaybackRate = renderer?.playbackRate ?? .normal
            renderer = nil
            loadError = nil

            guard let selectedEffect else {
                return
            }

            do {
                let device = MTLCreateSystemDefaultDevice()!
                let newRenderer = try EffectViewerEffectRenderer(
                    device: device,
                    configuration: .default,
                    effectID: selectedEffect.effectID,
                    resourceManager: resourceManager,
                    ez2strEffectCatalog: ez2strEffectCatalog
                )
                newRenderer.isLooping = previousIsLooping
                newRenderer.playbackRate = previousPlaybackRate
                renderer = newRenderer
            } catch {
                loadError = error
            }
        }
    }
}

private struct EffectViewerStageBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let centerColor = Color(
                red: Double(EffectViewerStageRenderer.centerCharcoalColor.x),
                green: Double(EffectViewerStageRenderer.centerCharcoalColor.y),
                blue: Double(EffectViewerStageRenderer.centerCharcoalColor.z)
            )
            let edgeColor = Color(
                red: Double(EffectViewerStageRenderer.edgeCharcoalColor.x),
                green: Double(EffectViewerStageRenderer.edgeCharcoalColor.y),
                blue: Double(EffectViewerStageRenderer.edgeCharcoalColor.z)
            )
            let radius = max(geometry.size.width, geometry.size.height) * 0.65

            RadialGradient(
                colors: [centerColor, edgeColor],
                center: .center,
                startRadius: 0,
                endRadius: max(radius, 1)
            )
        }
    }
}

private extension View {
    @ViewBuilder
    func adaptiveStageCapsuleBackground() -> some View {
        #if os(visionOS)
        self.background(.ultraThinMaterial, in: Capsule())
        #else
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(.regular, in: Capsule())
        } else {
            self.background(.ultraThinMaterial, in: Capsule())
        }
        #endif
    }
}
