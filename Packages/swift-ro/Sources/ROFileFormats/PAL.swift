//
//  PAL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//

import Foundation
import ROCore

public struct PAL {
    public var colors: [Color] = []

    public init(data: Data) throws {
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
