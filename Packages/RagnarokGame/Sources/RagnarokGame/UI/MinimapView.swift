//
//  MinimapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/21.
//

import CoreGraphics
import RagnarokSprite
import SwiftUI

private let mapSize: CGFloat = 96
private let zoomFactors = [1, 10, 6, 3, 2]

struct MinimapView: View {
    var scene: MapScene

    @Environment(GameContext.self) private var gameContext

    @State private var zoomLevel = 0
    @State private var mapImage: CGImage?

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            MinimapMapView(
                scene: scene,
                mapImage: mapImage,
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
            mapImage = try? await gameContext.resourceManager.mapImage(forMapName: mapName).cgImage
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
    var zoomFactor: Int
    var showsFullMap: Bool

    var body: some View {
        ZStack {
            if let mapImage {
                Image(decorative: mapImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
                    .frame(
                        width: mapDisplaySize(for: mapImage).width,
                        height: mapDisplaySize(for: mapImage).height
                    )
                    .position(mapCenter(for: mapImage, playerPosition: scene.state.playerPosition))
            }

            MinimapArrowView()
                .rotationEffect(arrowRotation(for: scene.state.playerDirection))
                .position(arrowPosition(for: scene.state.playerPosition))
        }
        .frame(width: mapSize, height: mapSize)
        .clipped()
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

    private func arrowRotation(for direction: SpriteDirection) -> Angle {
        .degrees(Double((direction.rawValue + 4) * 45))
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

private struct MinimapArrowView: View {
    var body: some View {
        MinimapArrowShape()
            .fill(.white)
            .frame(width: 12, height: 12)
            .clipped()
            .overlay {
                Color(red: 1, green: 0, blue: 0)
                    .frame(width: 2, height: 2)
            }
    }
}

private struct MinimapArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let corners = [
            CGPoint(x: 6, y: -2.75),
            CGPoint(x: 12.5, y: 12),
            CGPoint(x: 6, y: 7.25),
            CGPoint(x: -0.5, y: 12),
        ]

        var path = Path()
        path.addLines(corners.map { corner in
            CGPoint(
                x: rect.minX + rect.width * corner.x / 12,
                y: rect.minY + rect.height * corner.y / 12
            )
        })
        path.closeSubpath()
        return path
    }
}
