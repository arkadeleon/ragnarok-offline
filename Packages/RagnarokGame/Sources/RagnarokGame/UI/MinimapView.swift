//
//  MinimapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/21.
//

import CoreGraphics
import RagnarokResources
import SwiftUI

private let mapSize: CGFloat = 96
private let zoomFactors = [1, 10, 6, 3, 2]

struct MinimapView: View {
    var scene: MapScene

    @Environment(GameContext.self) private var gameContext

    @State private var zoomLevel = 0
    @State private var mapImage: CGImage?
    @State private var arrowImage: CGImage?

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            MinimapMapView(
                scene: scene,
                mapImage: mapImage,
                arrowImage: arrowImage,
                zoomFactor: zoomFactors[zoomLevel],
                showsFullMap: zoomLevel == 0
            )

            HStack(spacing: 0) {
                Button(action: zoomIn) {
                    Image(systemName: "plus")
                        .font(.game(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 1, y: 1)
                        .frame(width: 24, height: 24)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .disabled(zoomLevel == zoomFactors.count - 1)

                Button(action: zoomOut) {
                    Image(systemName: "minus")
                        .font(.game(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 1, y: 1)
                        .frame(width: 24, height: 24)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .disabled(zoomLevel == 0)
            }
            .offset(x: 6)
        }
        .frame(width: mapSize)
        .task(id: scene.mapName) {
            let mapName = scene.mapName.split(separator: ".", maxSplits: 1).first.map(String.init) ?? scene.mapName
            let mapImagePath = ResourcePath.generateMapImagePath(mapName: mapName)
            let arrowImagePath = ResourcePath.userInterfaceDirectory.appending(["map", "map_arrow.bmp"])

            async let mapImageResource = try? gameContext.resourceManager.image(at: mapImagePath, removesMagentaPixels: true)
            async let arrowImageResource = try? gameContext.resourceManager.image(at: arrowImagePath, removesMagentaPixels: true)

            mapImage = await mapImageResource?.cgImage
            arrowImage = await arrowImageResource?.cgImage
        }
    }

    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomLevel = min(zoomLevel + 1, zoomFactors.count - 1)
        }
    }

    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomLevel = max(zoomLevel - 1, 0)
        }
    }
}

private struct MinimapMapView: View {
    var scene: MapScene
    var mapImage: CGImage?
    var arrowImage: CGImage?
    var zoomFactor: Int
    var showsFullMap: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { _ in
            let position = scene.player.gridPosition

            ZStack {
                if let mapImage {
                    Image(decorative: mapImage, scale: 1)
                        .resizable()
                        .interpolation(.none)
                        .frame(
                            width: mapDisplaySize(for: mapImage).width,
                            height: mapDisplaySize(for: mapImage).height
                        )
                        .position(mapCenter(for: mapImage, playerPosition: position))
                }

                if let arrowImage {
                    Image(decorative: arrowImage, scale: 1)
                        .interpolation(.none)
                        .rotationEffect(arrowRotation)
                        .position(arrowPosition(for: position))
                }
            }
            .frame(width: mapSize, height: mapSize)
            .clipped()
        }
        .allowsHitTesting(false)
    }

    private func mapDisplaySize(for image: CGImage) -> CGSize {
        guard !showsFullMap else {
            return CGSize(width: mapSize, height: mapSize)
        }

        let sourceSize = CGFloat(zoomFactor * 40)
        let scale = mapSize / sourceSize
        return CGSize(
            width: CGFloat(image.width) * scale,
            height: CGFloat(image.height) * scale
        )
    }

    private func mapCenter(for image: CGImage, playerPosition: SIMD2<Int>) -> CGPoint {
        guard !showsFullMap else {
            return CGPoint(x: mapSize / 2, y: mapSize / 2)
        }

        let sourceSize = CGFloat(zoomFactor * 40)
        let scale = mapSize / sourceSize
        let sourceCenter = sourcePoint(for: playerPosition, in: image)
        return CGPoint(
            x: mapSize / 2 + (CGFloat(image.width) / 2 - sourceCenter.x) * scale,
            y: mapSize / 2 + (CGFloat(image.height) / 2 - sourceCenter.y) * scale
        )
    }

    private var arrowRotation: Angle {
        let direction = scene.player.movement?.direction ?? scene.player.action.direction
        return .degrees(Double((direction.rawValue + 4) * 45))
    }

    private func arrowPosition(for position: SIMD2<Int>) -> CGPoint {
        if showsFullMap {
            projectedPoint(for: position)
        } else {
            CGPoint(x: mapSize / 2, y: mapSize / 2)
        }
    }

    private func sourcePoint(for position: SIMD2<Int>, in image: CGImage) -> CGPoint {
        let projected = projectedPoint(for: position)
        return CGPoint(
            x: projected.x / mapSize * CGFloat(image.width),
            y: projected.y / mapSize * CGFloat(image.height)
        )
    }

    private func projectedPoint(for position: SIMD2<Int>) -> CGPoint {
        let width = CGFloat(scene.mapGrid.width)
        let height = CGFloat(scene.mapGrid.height)
        let maximumDimension = max(width, height)
        let scale = mapSize / maximumDimension
        let startX = (maximumDimension - width) / 2 * scale
        let startY = (height - maximumDimension) / 2 * scale

        return CGPoint(
            x: startX + CGFloat(position.x) * scale,
            y: startY + mapSize - CGFloat(position.y) * scale
        )
    }
}
