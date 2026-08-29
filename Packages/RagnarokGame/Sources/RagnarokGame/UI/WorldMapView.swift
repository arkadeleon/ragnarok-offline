//
//  WorldMapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/30.
//

import CoreGraphics
import RagnarokResources
import RagnarokScript
import SwiftUI

// Every world map image is this size, and the rects are pixels in it.
private let imageSize = CGSize(width: 1280, height: 1024)

struct WorldMapView: View {
    var currentMapName: String
    var onClose: () -> Void = {}

    @Environment(GameContext.self) private var gameContext

    @State private var worlds: [WorldViewData.World] = []
    @State private var selectedWorldIndex = 0
    @State private var mapImage: CGImage?

    var body: some View {
        WorldMapImageView(world: selectedWorld, image: mapImage, currentMapName: currentMapName)
            .background {
                Color.black.ignoresSafeArea()
            }
            .overlay(alignment: .topLeading) {
                Menu {
                    ForEach(worlds.indices, id: \.self) { index in
                        Button(worlds[index].name) {
                            selectedWorldIndex = index
                        }
                    }
                } label: {
                    Text(selectedWorld?.name ?? "")
                }
                .menuStyle(.button)
                .buttonStyle(.game)
                .frame(width: 120, height: 20)
                .disabled(worlds.isEmpty)
                .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                .padding(10)
            }
            .overlay(alignment: .topTrailing) {
                Button("close", action: onClose)
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                    .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                    .padding(10)
            }
            .task {
                worlds = await gameContext.resourceManager.worldViewData().worlds
            }
            .task(id: selectedWorld?.imageName) {
                mapImage = nil

                guard let imageName = selectedWorld?.imageName else {
                    return
                }

                let imagePath = ResourcePath.userInterfaceDirectory.appending([imageName])
                mapImage = try? await gameContext.resourceManager.image(at: imagePath).cgImage
            }
    }

    private var selectedWorld: WorldViewData.World? {
        worlds.indices.contains(selectedWorldIndex) ? worlds[selectedWorldIndex] : nil
    }
}

private struct WorldMapImageView: View {
    var world: WorldViewData.World?
    var image: CGImage?
    var currentMapName: String

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / imageSize.width, geometry.size.height / imageSize.height)

            ZStack {
                if let image {
                    Image(decorative: image, scale: 1)
                        .resizable()
                }

                if let world {
                    WorldMapSectionsView(world: world, currentMapName: currentMapName, scale: scale)
                }
            }
            .frame(width: imageSize.width * scale, height: imageSize.height * scale)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

private struct WorldMapSectionsView: View {
    var world: WorldViewData.World
    var currentMapName: String
    var scale: CGFloat

    var body: some View {
        Canvas { context, _ in
            let entrancesByGroupIndex = Dictionary(
                world.dungeons.map({ ($0.groupIndex, $0) }),
                uniquingKeysWith: { first, _ in first }
            )

            for map in world.maps {
                guard let dungeon = entrancesByGroupIndex[map.groupIndex],
                      let line = connector(from: dungeon.rect.scaled(by: scale), to: map.rect.scaled(by: scale)) else {
                    continue
                }

                context.stroke(line, with: .color(Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.5))), lineWidth: 1)
            }

            // Floors of the same dungeon often share a spot. Filling every one of
            // them would stack up to a solid box, so only the first is filled.
            var filledOrigins: Set<SIMD2<Int>> = []

            let entrances = world.dungeons.map({ ($0.rect, true) })
            let sections = world.maps.map({ ($0.rect, entrancesByGroupIndex[$0.groupIndex] != nil) })

            for (rect, isDungeon) in entrances + sections {
                let path = Path(roundedRect: rect.scaled(by: scale), cornerRadius: 4)

                guard isDungeon else {
                    context.stroke(path, with: .color(Color(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.4784313725))), lineWidth: 1)
                    continue
                }

                if filledOrigins.insert(SIMD2(rect.left, rect.top)).inserted {
                    context.fill(path, with: .color(Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.4))))
                }
                context.stroke(path, with: .color(Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.6))), lineWidth: 1)
            }

            if let currentMap = world.maps.first(where: { $0.mapName.mapNameStem == currentMapName.mapNameStem }) {
                let path = Path(roundedRect: currentMap.rect.scaled(by: scale), cornerRadius: 4)
                context.fill(path, with: .color(Color(#colorLiteral(red: 1, green: 0.5019607843, blue: 0, alpha: 0.5))))
                context.stroke(path, with: .color(Color(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.4784313725))), lineWidth: 1)
            }
        }
    }

    // A line from the edge of a dungeon entrance to the edge of one of its floors.
    private func connector(from entrance: CGRect, to floor: CGRect) -> Path? {
        let start = CGPoint(x: entrance.midX, y: entrance.midY)
        let end = CGPoint(x: floor.midX, y: floor.midY)

        let distance = hypot(end.x - start.x, end.y - start.y)
        let angle = atan2(end.y - start.y, end.x - start.x)

        let startOffset = radius(of: entrance.size, at: angle)
        let endOffset = radius(of: floor.size, at: angle)
        guard distance > startOffset + endOffset else {
            return nil
        }

        var path = Path()
        path.move(to: CGPoint(x: start.x + cos(angle) * startOffset, y: start.y + sin(angle) * startOffset))
        path.addLine(to: CGPoint(x: end.x - cos(angle) * endOffset, y: end.y - sin(angle) * endOffset))
        return path
    }

    // The distance from the center of a rect to its edge along an angle.
    private func radius(of size: CGSize, at angle: CGFloat) -> CGFloat {
        let absCos = abs(cos(angle))
        let absSin = abs(sin(angle))

        if size.width * absSin <= size.height * absCos {
            return size.width / (2 * absCos)
        } else {
            return size.height / (2 * absSin)
        }
    }
}

extension String {
    /// The map name without its `gat` or `rsw` extension.
    fileprivate var mapNameStem: String {
        split(separator: ".", maxSplits: 1).first.map(String.init) ?? self
    }
}

extension WorldViewData.Rect {
    fileprivate func scaled(by scale: CGFloat) -> CGRect {
        CGRect(
            x: CGFloat(left) * scale,
            y: CGFloat(top) * scale,
            width: CGFloat(right - left) * scale,
            height: CGFloat(bottom - top) * scale
        )
    }
}

#Preview {
    WorldMapView(currentMapName: "prontera.gat")
        .environment(GameContext.testing)
}
