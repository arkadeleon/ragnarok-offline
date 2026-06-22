//
//  TimeInterval+.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/6/22.
//

import Foundation

extension TimeInterval {
    static func milliseconds<T: BinaryInteger>(_ value: T) -> TimeInterval {
        TimeInterval(value) / 1000
    }
}
