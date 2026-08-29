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
    var onClose: () -> Void = {}

    @Environment(GameContext.self) private var gameContext

    @State private var worlds: [WorldViewData.World] = []
    @State private var selectedWorldIndex = 0
    @State private var mapImage: CGImage?

    var body: some View {
        WorldMapImageView(world: selectedWorld, image: mapImage)
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

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / imageSize.width, geometry.size.height / imageSize.height)

            ZStack {
                if let image {
                    Image(decorative: image, scale: 1)
                        .resizable()
                }

                if let world {
                    Canvas { context, _ in
                        for map in world.maps {
                            let rect = map.rect.scaled(by: scale)
                            let path = Path(roundedRect: rect, cornerRadius: 4)
                            context.stroke(path, with: .color(Color(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.4784313725))), lineWidth: 1)
                        }
                    }
                }
            }
            .frame(width: imageSize.width * scale, height: imageSize.height * scale)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
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
    WorldMapView()
        .environment(GameContext.testing)
}
