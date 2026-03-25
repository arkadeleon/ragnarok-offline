//
//  Duration+TimeInterval.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Foundation

extension Duration {
    var timeInterval: TimeInterval {
        let components = components
        return Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
