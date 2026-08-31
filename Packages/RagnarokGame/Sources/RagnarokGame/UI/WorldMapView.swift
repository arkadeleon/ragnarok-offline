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

// A map or a dungeon entrance the player picked on the world map.
private enum WorldMapSection {
    case map(WorldViewData.Map)
    case dungeonEntrance(WorldViewData.DungeonEntrance)

    var name: String {
        switch self {
        case .map(let map): map.name
        case .dungeonEntrance(let entrance): entrance.name
        }
    }

    /// The map name with the rsw extension. A dungeon entrance has none.
    var mapName: String? {
        switch self {
        case .map(let map): map.mapName
        case .dungeonEntrance: nil
        }
    }

    var monsterLevel: String {
        switch self {
        case .map(let map): map.monsterLevel
        case .dungeonEntrance(let entrance): entrance.monsterLevel
        }
    }

    var rect: WorldViewData.Rect {
        switch self {
        case .map(let map): map.rect
        case .dungeonEntrance(let entrance): entrance.rect
        }
    }
}

struct WorldMapView: View {
    var currentMapName: String
    var onClose: () -> Void = {}

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var worlds: [WorldViewData.World] = []
    @State private var selectedWorldIndex = 0
    @State private var selectedSection: WorldMapSection?

    var body: some View {
        WorldMapImageView(world: selectedWorld, currentMapName: currentMapName, selectedSection: $selectedSection)
            .background {
                Color.black.ignoresSafeArea()
            }
            .overlay(alignment: .topLeading) {
                Menu("world") {
                    ForEach(worlds.indices, id: \.self) { index in
                        Button(worlds[index].name) {
                            selectedWorldIndex = index
                        }
                    }
                }
                .menuStyle(.button)
                .buttonStyle(.game)
                .frame(width: 60, height: 20)
                .padding(16)
                .disabled(worlds.isEmpty)
            }
            .overlay(alignment: .topTrailing) {
                Button("close", action: onClose)
                    .buttonStyle(.game)
                    .frame(width: 60, height: 20)
                    .padding(16)
            }
            .overlay(alignment: .bottomLeading) {
                if let selectedSection {
                    WorldMapSectionInfoView(section: selectedSection) {
                        teleport(to: selectedSection)
                    }
                    .padding(16)
                }
            }
            .task {
                worlds = await gameContext.resourceManager.worldViewData().worlds
            }
            .onChange(of: selectedWorldIndex) {
                selectedSection = nil
            }
    }

    private var selectedWorld: WorldViewData.World? {
        worlds.indices.contains(selectedWorldIndex) ? worlds[selectedWorldIndex] : nil
    }

    private func teleport(to section: WorldMapSection) {
        guard let mapName = section.mapName else {
            return
        }

        gameSession.sendMessage("@warp \(mapName.mapNameStem)")
        onClose()
    }
}

private struct WorldMapImageView: View {
    var world: WorldViewData.World?
    var currentMapName: String
    @Binding var selectedSection: WorldMapSection?

    @Environment(GameContext.self) private var gameContext

    @State private var worldImage: CGImage?

    @State private var viewport = WorldMapViewport()
    @GestureState private var gestureTransform = WorldMapViewport.Transform()

    var body: some View {
        GeometryReader { geometry in
            let fittedScale = min(geometry.size.width / imageSize.width, geometry.size.height / imageSize.height)
            let fittedMapSize = CGSize(width: imageSize.width * fittedScale, height: imageSize.height * fittedScale)
            let displayedViewport = viewport.applying(gestureTransform, containerSize: geometry.size, fittedMapSize: fittedMapSize)

            ZStack {
                ZStack {
                    if let worldImage {
                        Image(decorative: worldImage, scale: 1)
                            .resizable()
                    }

                    if let world {
                        WorldMapSectionsView(
                            world: world,
                            currentMapName: currentMapName,
                            selectedSection: selectedSection,
                            fittedScale: fittedScale,
                            zoomScale: displayedViewport.zoomScale
                        )
                    }
                }
                .frame(width: fittedMapSize.width, height: fittedMapSize.height)
                .scaleEffect(displayedViewport.zoomScale)
                .offset(displayedViewport.offset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .gesture(
                MagnifyGesture()
                    .simultaneously(with: DragGesture(minimumDistance: 8))
                    .updating($gestureTransform) { value, state, _ in
                        state = WorldMapViewport.Transform(
                            magnification: value.first?.magnification ?? 1,
                            anchor: value.first.map { CGPoint(x: $0.startAnchor.x, y: $0.startAnchor.y) },
                            translation: value.second?.translation ?? .zero
                        )
                    }
                    .onEnded { value in
                        let transform = WorldMapViewport.Transform(
                            magnification: value.first?.magnification ?? 1,
                            anchor: value.first.map { CGPoint(x: $0.startAnchor.x, y: $0.startAnchor.y) },
                            translation: value.second?.translation ?? .zero
                        )
                        viewport = viewport.applying(
                            transform,
                            containerSize: geometry.size,
                            fittedMapSize: fittedMapSize
                        )
                    }
            )
            .simultaneousGesture(
                SpatialTapGesture()
                    .onEnded { value in
                        selectedSection = section(
                            at: value.location,
                            viewport: displayedViewport,
                            containerSize: geometry.size,
                            fittedMapSize: fittedMapSize
                        )
                    }
            )
            .onChange(of: geometry.size) {
                viewport = viewport.clamped(containerSize: geometry.size, fittedMapSize: fittedMapSize)
            }
        }
        .clipped()
        .task(id: world?.imageName) {
            worldImage = nil
            viewport = WorldMapViewport()

            guard let imageName = world?.imageName else {
                return
            }

            let imagePath = ResourcePath.userInterfaceDirectory.appending([imageName])
            worldImage = try? await gameContext.resourceManager.image(at: imagePath).cgImage
        }
    }

    private func section(
        at location: CGPoint,
        viewport: WorldMapViewport,
        containerSize: CGSize,
        fittedMapSize: CGSize
    ) -> WorldMapSection? {
        guard let world,
              let point = viewport.imagePoint(at: location, containerSize: containerSize, fittedMapSize: fittedMapSize, imageSize: imageSize) else {
            return nil
        }

        // Every dungeon entrance sits inside a map, so the smaller target wins.
        if let entrance = world.dungeonEntrances.first(where: { $0.rect.contains(point) }) {
            return .dungeonEntrance(entrance)
        }

        // Floors of one dungeon share a rect, and the first of them is the one
        // drawn filled, so it stands for the whole stack.
        if let map = world.maps.first(where: { $0.rect.contains(point) }) {
            return .map(map)
        }

        return nil
    }
}

private struct WorldMapSectionsView: View {
    var world: WorldViewData.World
    var currentMapName: String
    var selectedSection: WorldMapSection?
    var fittedScale: CGFloat
    var zoomScale: CGFloat

    var body: some View {
        Canvas { context, _ in
            let entrancesByGroupIndex = Dictionary(
                world.dungeonEntrances.map({ ($0.groupIndex, $0) }),
                uniquingKeysWith: { first, _ in first }
            )

            for map in world.maps {
                guard let entrance = entrancesByGroupIndex[map.groupIndex],
                      let line = connector(from: entrance.rect.scaled(by: fittedScale), to: map.rect.scaled(by: fittedScale)) else {
                    continue
                }

                context.stroke(line, with: .color(Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.5))), lineWidth: strokeWidth)
            }

            // Floors of the same dungeon often share a spot. Filling every one of
            // them would stack up to a solid box, so only the first is filled.
            var filledOrigins: Set<SIMD2<Int>> = []

            let entrances = world.dungeonEntrances.map({ ($0.rect, true) })
            let sections = world.maps.map({ ($0.rect, entrancesByGroupIndex[$0.groupIndex] != nil) })

            for (rect, isDungeonEntrance) in entrances + sections {
                let path = Path(roundedRect: rect.scaled(by: fittedScale), cornerRadius: cornerRadius)

                guard isDungeonEntrance else {
                    context.stroke(path, with: .color(Color(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.4784313725))), lineWidth: strokeWidth)
                    continue
                }

                if filledOrigins.insert(SIMD2(rect.left, rect.top)).inserted {
                    context.fill(path, with: .color(Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.4))))
                }
                context.stroke(path, with: .color(Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.6))), lineWidth: strokeWidth)
            }

            if let currentMap = world.maps.first(where: { $0.mapName.mapNameStem == currentMapName.mapNameStem }) {
                let path = Path(roundedRect: currentMap.rect.scaled(by: fittedScale), cornerRadius: cornerRadius)
                context.fill(path, with: .color(Color(#colorLiteral(red: 1, green: 0.5019607843, blue: 0, alpha: 0.5))))
                context.stroke(path, with: .color(Color(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.4784313725))), lineWidth: strokeWidth)
            }

            if let selectedSection {
                let path = Path(roundedRect: selectedSection.rect.scaled(by: fittedScale), cornerRadius: cornerRadius)
                context.fill(path, with: .color(Color(#colorLiteral(red: 0, green: 0.5019607843, blue: 1, alpha: 0.5))))
                context.stroke(path, with: .color(Color(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.4784313725))), lineWidth: strokeWidth)
            }
        }
    }

    private var strokeWidth: CGFloat {
        1 / zoomScale
    }

    private var cornerRadius: CGFloat {
        4 / zoomScale
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

private struct WorldMapSectionInfoView: View {
    var section: WorldMapSection
    var teleportAction: () -> Void

    @Environment(GameContext.self) private var gameContext

    @State private var mapImage: CGImage?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))

                if let mapImage {
                    Image(decorative: mapImage, scale: 1)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 150, height: 150)
            .clipped()

            Text(mapName)
                .font(.game(weight: .bold))
                .foregroundStyle(Color(#colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)))
                .frame(maxWidth: 150)
                .padding(.top, 3)

            if let mapName = section.mapName {
                Text(mapName.mapNameStem)
                    .font(.game(size: 11))
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 2)
            }

            if !section.monsterLevel.isEmpty {
                Text(verbatim: "Lv. \(section.monsterLevel)")
                    .font(.game(size: 11))
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 2)
            }

            Button("teleport", action: teleportAction)
                .buttonStyle(.game)
                .frame(width: 60, height: 20)
                .padding(.top, 3)
                .disabled(section.mapName == nil)
        }
        .multilineTextAlignment(.center)
        .padding(5)
        .background(Color.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)), lineWidth: 1)
        }
        .task(id: section.mapName) {
            mapImage = nil

            guard let mapName = section.mapName else {
                return
            }

            let imagePath = ResourcePath.generateMapImagePath(mapName: mapName.mapNameStem)
            mapImage = try? await gameContext.resourceManager.image(at: imagePath, removesMagentaPixels: true).cgImage
        }
    }

    private var mapName: String {
        guard let mapName = section.mapName,
              let localizedMapName = gameContext.mapNameTable.localizedMapName(forMapName: mapName.mapNameStem) else {
            return section.name
        }
        return localizedMapName
    }
}

extension String {
    /// The map name without its `gat` or `rsw` extension.
    fileprivate var mapNameStem: String {
        split(separator: ".", maxSplits: 1).first.map(String.init) ?? self
    }
}

extension WorldViewData.Rect {
    fileprivate func contains(_ point: CGPoint) -> Bool {
        CGFloat(left) <= point.x && point.x < CGFloat(right) && CGFloat(top) <= point.y && point.y < CGFloat(bottom)
    }

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
    let gameSession = GameSession.testing

    WorldMapView(currentMapName: "prontera.gat")
        .environment(gameSession)
        .environment(gameSession.context)
}
