//
//  MetalOverlayView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/30.
//

#if !os(visionOS)

import SwiftUI

struct MetalOverlayView: View {
    var overlay: MetalOverlayState

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

#endif
