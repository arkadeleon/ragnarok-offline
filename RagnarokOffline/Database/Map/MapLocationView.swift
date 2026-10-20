//
//  MapLocationView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct MapLocation: Hashable {
    var x: Int
    var y: Int
}

struct MapLocationView: View {
    var map: MapModel
    var locations: [MapLocation]

    var body: some View {
        ZStack {
            if let mapImage = map.originalImage {
                Image(decorative: mapImage.cgImage, scale: 1)
                    .resizable()
            } else {
                Rectangle()
                    .stroke(Color.secondary, lineWidth: 1)
            }
        }
        .overlay {
            GeometryReader { geometry in
                ForEach(locations, id: \.self) { location in
                    let point = point(for: location)
                    Circle()
                        .fill(Color.red)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 10, height: 10)
                        .position(
                            x: point.x * geometry.size.width,
                            y: point.y * geometry.size.height
                        )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 300)
        .task {
            await map.fetchOriginalImage()
        }
    }

    private func point(for location: MapLocation) -> CGPoint {
        let xs = Double(map.xs)
        let ys = Double(map.ys)
        let size = max(xs, ys)
        return CGPoint(
            x: ((size - xs) / 2 + Double(location.x) + 0.5) / size,
            y: 1 - ((size - ys) / 2 + Double(location.y) + 0.5) / size
        )
    }
}
