//
//  SIMD+Encodable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/30.
//

import simd

extension simd_float3x3: Encodable {
    public func encode(to encoder: Encoder) throws {
        let columns = [columns.0, columns.1, columns.2]
        try columns.encode(to: encoder)
    }
}
