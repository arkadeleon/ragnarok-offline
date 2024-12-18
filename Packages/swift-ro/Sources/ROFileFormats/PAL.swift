//
//  PAL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//

import Foundation
import ROCore

public struct PAL: BinaryDecodable {
    public var colors: [Color] = []

    public init(data: Data) throws {
        let decoder = BinaryDecoder(data: data)
        self = try decoder.decode(PAL.self)
    }

    public init(from decoder: BinaryDecoder) throws {
        for _ in 0..<256 {
            let color = try decoder.decode(Color.self)
            colors.append(color)
        }
    }
}
