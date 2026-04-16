//
//  ShieldNameTable.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2026/4/16.
//

import TextEncoding

// Ported from zrenderer:
// https://github.com/zhad3/zrenderer/blob/main/resolver_data/shield_names.txt
enum ShieldNameTable {
    private static let table: [Int : String] = [
        1: "_가드",
        2: "_버클러",
        3: "_쉴드",
        4: "_미러쉴드",
    ]

    static func name(for shieldID: Int) -> String? {
        table[shieldID].flatMap(K2L)
    }
}
