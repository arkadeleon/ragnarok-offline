//
//  ShieldNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/11.
//

struct ShieldNameTable: Sendable {
    static let current = ShieldNameTable()

    let shieldNamesByID: [Int : String] = [
        1: "_가드",
        2: "_버클러",
        3: "_쉴드",
        4: "_미러쉴드",
    ]

    func shieldName(for shieldID: Int) -> String? {
        shieldNamesByID[shieldID]
    }
}
