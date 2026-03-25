//
//  MapSceneOverlayView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/30.
//

import SwiftUI

struct MapSceneOverlayView: View {
    var overlay: MapSceneOverlay

    var body: some View {
        GeometryReader { _ in
            ForEach(Array(overlay.gauges.values)) { gauge in
                GaugeView(
                    hp: gauge.hp,
                    maxHp: gauge.maxHp,
                    sp: gauge.sp,
                    maxSp: gauge.maxSp,
                    objectType: gauge.objectType
                )
                .position(gauge.screenPosition)
            }
        }
        .allowsHitTesting(false)
    }
}
