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
    @State private var effects: [EffectViewerEffect] = EffectViewerEffect.all
    @State private var ez2strEffectCatalog: EZ2STREffectCatalog?
    @State private var targetSprite: EffectViewerTargetSprite?
    @State private var showsTarget = false
    @State private var renderer: EffectViewerEffectRenderer?
    @State private var loadError: (any Error)?

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                EffectViewerStageBackground()

                if let renderer, selectedEffect != nil {
                    MetalViewContainer(renderer: renderer)
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
                        .frame(height: 36)
                        .adaptiveStageCapsuleBackground()
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: "effect", in: effectNamespace)
                    .padding(12)
                }
            }
            .overlay(alignment: .topTrailing) {
                if selectedEffect != nil {
                    Button {
                        showsTarget.toggle()
                        renderer?.showsTarget = showsTarget
                    } label: {
                        Image(systemName: showsTarget ? "person" : "person.slash")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(showsTarget ? .primary : .secondary)
                            .frame(width: 36, height: 36)
                            .adaptiveStageCapsuleBackground()
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(targetSprite == nil)
                    .padding(12)
                }
            }
            .environment(\.colorScheme, .dark)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            EffectViewerPlaybackControlsView(renderer: selectedEffect == nil ? nil : renderer)
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
            async let catalogTask = EZ2STREffectCatalog.load(from: resourceManager)
            let device = MTLCreateSystemDefaultDevice()
            async let spriteTask: EffectViewerTargetSprite? = {
                guard let device else {
                    return nil
                }
                return await EffectViewerTargetSprite.loadNovice(device: device, resourceManager: resourceManager)
            }()

            let loadedCatalog = await catalogTask
            ez2strEffectCatalog = loadedCatalog
            effects = EffectViewerEffect.all(ez2strEffectCatalog: loadedCatalog)
            renderer?.updateEZ2STREffectCatalog(loadedCatalog)

            let loadedSprite = await spriteTask
            targetSprite = loadedSprite
            renderer?.targetSprite = loadedSprite
        }
        .task(id: selectedEffect) {
            loadError = nil

            guard let selectedEffect else {
                renderer?.load(effectID: nil)
                return
            }

            if let renderer {
                renderer.load(effectID: selectedEffect.effectID)
                return
            }

            guard let device = MTLCreateSystemDefaultDevice() else {
                return
            }

            do {
                let newRenderer = try EffectViewerEffectRenderer(
                    device: device,
                    configuration: .default,
                    effectID: selectedEffect.effectID,
                    resourceManager: resourceManager,
                    ez2strEffectCatalog: ez2strEffectCatalog,
                    targetSprite: targetSprite
                )
                newRenderer.showsTarget = showsTarget
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
            self.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            self.background(.ultraThinMaterial, in: Capsule())
        }
        #endif
    }
}
