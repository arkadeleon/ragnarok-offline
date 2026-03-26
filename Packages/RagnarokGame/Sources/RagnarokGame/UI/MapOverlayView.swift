//
//  MapOverlayView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/30.
//

import SwiftUI

struct MapOverlayView: View {
    var overlay: MapOverlayState

    var body: some View {
        GeometryReader { _ in
            ForEach(Array(overlay.gauges.values)) { gauge in
                if let screenPosition = gauge.screenPosition {
                    GaugeView(
                        hp: gauge.hp,
                        maxHp: gauge.maxHp,
                        sp: gauge.sp,
                        maxSp: gauge.maxSp,
                        objectType: gauge.objectType
                    )
                    .position(screenPosition)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
