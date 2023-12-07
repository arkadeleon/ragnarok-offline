//
//  PAL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

struct PAL: Encodable {
    var colors: [Color] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        for _ in 0..<256 {
            let color = try Color(from: reader)
            colors.append(color)
        }
    }
}
