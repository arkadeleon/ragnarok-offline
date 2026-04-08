//
//  SkyboxConfiguration.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/8.
//

import CoreGraphics
import RagnarokFileFormats

func angularDistance(_ a: Float, _ b: Float) -> Float {
    let d = abs(a - b).truncatingRemainder(dividingBy: 360)
    return min(d, 360 - d)
}

struct SkyboxConfiguration {
    var center: SIMD3<Float> = .zero
    var radius: Float = 250
    var topColor = CGColor(red: 0.2, green: 0.4, blue: 0.85, alpha: 1.0)
    var horizonColor = CGColor(red: 0.6, green: 0.75, blue: 0.95, alpha: 1.0)
    var bottomColor = CGColor(red: 0.4, green: 0.55, blue: 0.75, alpha: 1.0)

    static func generate(light: RSW.Light, mapWidth: Int, mapHeight: Int) -> SkyboxConfiguration {
        var longitude = Float(light.longitude).truncatingRemainder(dividingBy: 360)
        longitude = longitude < 0 ? longitude + 360 : longitude

        let isEvening = angularDistance(longitude, 0) < 45 || angularDistance(longitude, 180) < 45
        let isMorning = angularDistance(longitude, 90) < 45 || angularDistance(longitude, 270) < 45

        let centerX = Float(mapWidth) / 2
        let centerZ = -Float(mapHeight) / 2
        let center: SIMD3<Float> = [centerX, 0, centerZ]

        let diagonal = sqrtf(Float(mapWidth * mapWidth + mapHeight * mapHeight))
        let cameraMargin: Float = 200
        let radius = diagonal / 2 + cameraMargin

        if isEvening {
            return SkyboxConfiguration(
                center: center,
                radius: radius,
                topColor: CGColor(red: 0.15, green: 0.1, blue: 0.3, alpha: 1.0),
                horizonColor: CGColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0),
                bottomColor: CGColor(red: 0.4, green: 0.3, blue: 0.35, alpha: 1.0)
            )
        }

        if isMorning {
            return SkyboxConfiguration(
                center: center,
                radius: radius,
                topColor: CGColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0),
                horizonColor: CGColor(red: 0.95, green: 0.75, blue: 0.6, alpha: 1.0),
                bottomColor: CGColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
            )
        }

        let ambient = (
            r: CGFloat(light.ambientRed),
            g: CGFloat(light.ambientGreen),
            b: CGFloat(light.ambientBlue)
        )

        return SkyboxConfiguration(
            center: center,
            radius: radius,
            topColor: CGColor(
                red: 0.15 + ambient.r * 0.1,
                green: 0.35 + ambient.g * 0.1,
                blue: 0.8 + ambient.b * 0.1,
                alpha: 1.0
            ),
            horizonColor: CGColor(red: 0.55, green: 0.7, blue: 0.92, alpha: 1.0),
            bottomColor: CGColor(red: 0.35, green: 0.5, blue: 0.72, alpha: 1.0)
        )
    }
}
