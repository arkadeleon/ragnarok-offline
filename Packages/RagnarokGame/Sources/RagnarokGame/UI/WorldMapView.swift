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

// The map preview in the info window is this wide and tall.
private let previewSize: CGFloat = 150

struct WorldMapView: View {
    var currentMapName: String
    var onClose: () -> Void = {}

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var worlds: [WorldViewData.World] = []
    @State private var selectedWorld: WorldViewData.World?
    @State private var selectedMap: WorldViewData.Map?
    @State private var showsMapPreviews = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let selectedWorld {
                WorldMapImageView(
                    world: selectedWorld,
                    currentMapName: currentMapName,
                    showsMapPreviews: showsMapPreviews,
                    selectedMap: $selectedMap
                )
            }
        }
        .overlay(alignment: .topLeading) {
            Menu("world") {
                ForEach(worlds, id: \.name) { world in
                    Button(world.name) {
                        selectedWorld = world
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
            WorldMapInfoView(maps: selectableMaps, selectedMap: $selectedMap) { map in
                gameSession.sendMessage("@warp \(map.mapName.mapNameStem)")
                onClose()
            }
            .padding(16)
        }
        .overlay(alignment: .bottomTrailing) {
            Button(showsMapPreviews ? "hide maps" : "show maps") {
                showsMapPreviews.toggle()
            }
            .buttonStyle(.game)
            .frame(width: 80, height: 20)
            .padding(16)
        }
        .task {
            worlds = await gameContext.resourceManager.worldViewData().worlds
            selectedWorld = worlds.first
        }
        .onChange(of: selectedWorld) {
            selectedMap = nil
        }
    }

    // Floors of one dungeon are drawn on the same spot, so picking one map picks them all.
    private var selectableMaps: [WorldViewData.Map] {
        guard let selectedWorld, let selectedMap else {
            return []
        }
        return selectedWorld.maps.filter { $0.rect == selectedMap.rect }
    }
}

private struct WorldMapImageView: View {
    var world: WorldViewData.World
    var currentMapName: String
    var showsMapPreviews: Bool
    @Binding var selectedMap: WorldViewData.Map?

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
                if let worldImage {
                    Image(decorative: worldImage, scale: 1)
                        .resizable()
                }

                if showsMapPreviews {
                    WorldMapPreviewsView(world: world, fittedScale: fittedScale)
                }

                WorldMapOverlayView(
                    world: world,
                    currentMapName: currentMapName,
                    selectedMap: selectedMap,
                    fittedScale: fittedScale,
                    zoomScale: displayedViewport.zoomScale
                )
            }
            .frame(width: fittedMapSize.width, height: fittedMapSize.height)
            .scaleEffect(displayedViewport.zoomScale)
            .offset(displayedViewport.offset)
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
                        selectedMap = map(
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
        .task(id: world.imageName) {
            worldImage = nil
            viewport = WorldMapViewport()

            let imagePath = ResourcePath.userInterfaceDirectory.appending([world.imageName])
            worldImage = try? await gameContext.resourceManager.image(at: imagePath).cgImage
        }
    }

    private func map(
        at location: CGPoint,
        viewport: WorldMapViewport,
        containerSize: CGSize,
        fittedMapSize: CGSize
    ) -> WorldViewData.Map? {
        guard let point = viewport.imagePoint(at: location, containerSize: containerSize, fittedMapSize: fittedMapSize, imageSize: imageSize) else {
            return nil
        }

        // Floors of one dungeon share a rect, so the first of them stands for the spot.
        return world.maps.first(where: { $0.rect.cgRect.contains(point) })
    }
}

private struct WorldMapOverlayView: View {
    var world: WorldViewData.World
    var currentMapName: String
    var selectedMap: WorldViewData.Map?
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
            let maps = world.maps.map({ ($0.rect, entrancesByGroupIndex[$0.groupIndex] != nil) })

            for (rect, isDungeonEntrance) in entrances + maps {
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

            // A dungeon is named on the floors its entrance points to, not on the
            // entrance itself.
            for entrance in world.dungeonEntrances {
                guard let map = world.maps.first(where: { $0.groupIndex == entrance.groupIndex }) else {
                    continue
                }

                let rect = map.rect.scaled(by: fittedScale)
                let text = Text(entrance.name)
                    .font(.game(size: 11 * fittedScale))
                    .foregroundStyle(Color.white)
                context.draw(text, at: CGPoint(x: rect.midX, y: rect.midY), anchor: .center)
            }

            if let currentMap = world.maps.first(where: { $0.mapName.mapNameStem == currentMapName.mapNameStem }) {
                let path = Path(roundedRect: currentMap.rect.scaled(by: fittedScale), cornerRadius: cornerRadius)
                context.fill(path, with: .color(Color(#colorLiteral(red: 1, green: 0.5019607843, blue: 0, alpha: 0.5))))
                context.stroke(path, with: .color(Color(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.4784313725))), lineWidth: strokeWidth)
            }

            if let selectedMap {
                let path = Path(roundedRect: selectedMap.rect.scaled(by: fittedScale), cornerRadius: cornerRadius)
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

private struct WorldMapPreviewsView: View {
    var world: WorldViewData.World
    var fittedScale: CGFloat

    var body: some View {
        ZStack {
            ForEach(maps, id: \.mapName) { map in
                let rect = map.rect.scaled(by: fittedScale)
                MapPreviewImage(map: map, thumbnailPixelSize: CGSize(width: 60, height: 60))
                    .frame(width: rect.width, height: rect.height)
                    .clipped()
                    .position(x: rect.midX, y: rect.midY)
            }
        }
    }

    private var maps: [WorldViewData.Map] {
        let dungeonGroupIndices = Set(world.dungeonEntrances.map(\.groupIndex))
        return world.maps.filter { !dungeonGroupIndices.contains($0.groupIndex) }
    }
}

private struct WorldMapInfoView: View {
    var maps: [WorldViewData.Map]
    @Binding var selectedMap: WorldViewData.Map?
    var teleportAction: (WorldViewData.Map) -> Void

    @Environment(GameContext.self) private var gameContext

    var body: some View {
        if let map = selectedMap {
            GameWindow {
                VStack(spacing: 4) {
                    MapPreviewImage(map: map)
                        .frame(width: previewSize, height: previewSize)
                        .background(Color(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)))
                        .clipped()

                    if maps.count > 1 {
                        MapStackThumbnails(maps: maps, selectedMap: map) { map in
                            selectedMap = map
                        }
                    }

                    Text(name(of: map))
                        .font(.game(weight: .bold))
                        .foregroundStyle(Color.gameLabel)
                        .frame(maxWidth: previewSize)

                    Text(map.mapName.mapNameStem)
                        .font(.game(size: 11))
                        .foregroundStyle(Color.gameLabel)

                    if !map.monsterLevel.isEmpty {
                        Text(verbatim: "Lv. \(map.monsterLevel)")
                            .font(.game(size: 11))
                            .foregroundStyle(Color.gameLabel)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(4)
            } titleBar: {
                GameTitleBar {
                    selectedMap = nil
                }
            } bottomBar: {
                GameBottomBar {
                    Button("teleport") {
                        teleportAction(map)
                    }
                    .buttonStyle(.game)
                    .frame(width: 60, height: 20)
                }
            }
            .frame(width: previewSize + 8)
        }
    }

    private func name(of map: WorldViewData.Map) -> String {
        gameContext.mapNameTable.localizedMapName(forMapName: map.mapName.mapNameStem) ?? map.name
    }
}

private struct MapStackThumbnails: View {
    var maps: [WorldViewData.Map]
    var selectedMap: WorldViewData.Map
    var selectAction: (WorldViewData.Map) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(maps, id: \.mapName) { map in
                    Button {
                        selectAction(map)
                    } label: {
                        MapPreviewImage(map: map, thumbnailPixelSize: CGSize(width: 30, height: 30))
                            .frame(width: 30, height: 30)
                            .background(Color(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)))
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .overlay {
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(map == selectedMap ? Color(#colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)) : Color(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(width: previewSize)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct MapPreviewImage: View {
    var map: WorldViewData.Map
    var thumbnailPixelSize: CGSize?

    @Environment(GameContext.self) private var gameContext

    @State private var mapImage: CGImage?

    var body: some View {
        ZStack {
            if let mapImage {
                Image(decorative: mapImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fill)
            }
        }
        .task(id: map) {
            mapImage = nil
            mapImage = try? await gameContext.resourceManager.mapImage(forMapName: map.mapName.mapNameStem, thumbnailPixelSize: thumbnailPixelSize).cgImage
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
    let gameSession = GameSession.testing

    WorldMapView(currentMapName: "prontera.gat")
        .environment(gameSession)
        .environment(gameSession.context)
}
