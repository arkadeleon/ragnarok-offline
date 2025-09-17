//
//  MapCache.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/2.
//

import BinaryIO
import Foundation

struct MapCache: BinaryDecodable {
    var fileSize: UInt32
    var mapCount: UInt16
    var maps: [MapCache.MapInfo]

    init(from decoder: BinaryDecoder) throws {
        fileSize = try decoder.decode(UInt32.self)
        mapCount = try decoder.decode(UInt16.self)

        // alignment
        _ = try decoder.decode([UInt8].self, count: 2)

        maps = try decoder.decode([MapCache.MapInfo].self, count: Int(mapCount))
    }
}

extension MapCache {
    struct MapInfo: BinaryDecodable {
        var name: String
        var xs: Int16
        var ys: Int16
        var data: [UInt8]

        init(from decoder: BinaryDecoder) throws {
            name = try decoder.decode(String.self, lengthOfBytes: 12)
            xs = try decoder.decode(Int16.self)
            ys = try decoder.decode(Int16.self)

            let dataLength = try decoder.decode(Int32.self)
            data = try decoder.decode([UInt8].self, count: Int(dataLength))
        }
    }
}
