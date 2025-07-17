//
//  PAL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//

import BinaryIO
import Foundation

public struct PAL: FileFormat {
    public var colors: [RGBAColor] = []

    public init(from decoder: BinaryDecoder) throws {
        for _ in 0..<256 {
            let color = try decoder.decode(RGBAColor.self)
            colors.append(color)
        }
    }
}
