//
//  MapViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/9.
//

import Metal
import RagnarokRenderAssets
import RagnarokResources
import SwiftUI

struct MapViewer: View {
    var resourceManager: ResourceManager

    private let progress = Progress()

    @Environment(DatabaseModel.self) private var database

    @State private var selectedMap: MapModel?
    @State private var dragOffset: CGPoint = .zero
    @State private var magnification: CGFloat = 1

    var body: some View {
        ZStack {
            if let selectedMap {
                AsyncContentView {
                    try await loadRenderer(for: selectedMap.name)
                } content: { renderer in
                    MetalViewContainer(renderer: renderer)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let offset = CGPoint(
                                        x: dragOffset.x + value.translation.width,
                                        y: dragOffset.y + value.translation.height
                                    )
                                    renderer.camera.move(offset: CGPoint(x: offset.x, y: -offset.y))
                                }
                                .onEnded { value in
                                    dragOffset.x += value.translation.width
                                    dragOffset.y += value.translation.height
                                }
                        )
                        .simultaneousGesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    renderer.camera.update(
                                        magnification: magnification * value.magnification,
                                        dragTranslation: .zero
                                    )
                                }
                                .onEnded { value in
                                    magnification *= value.magnification
                                }
                        )
                } placeholder: {
                    ProgressView(progress)
                        .progressViewStyle(.circular)
                }
                .id(selectedMap.name)
            }
        }
        .navigationTitle("Map Viewer")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                MapPicker(selection: $selectedMap)
            }
        }
        .task {
            await database.fetchMaps()

            if selectedMap == nil {
                selectedMap = database.maps.first
            }
        }
        .onChange(of: selectedMap?.name) {
            dragOffset = .zero
            magnification = 1
        }
    }

    private func loadRenderer(for mapName: String) async throws -> RSWFilePreviewRenderer {
        let world = try await resourceManager.world(mapName: "\(mapName).rsw")
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            gat: world.gat,
            gnd: world.gnd,
            rsw: world.rsw,
            resourceManager: resourceManager,
            progress: progress
        )

        let device = MTLCreateSystemDefaultDevice()!
        let renderer = try RSWFilePreviewRenderer(device: device, worldAsset: worldAsset)
        return renderer
    }
}
