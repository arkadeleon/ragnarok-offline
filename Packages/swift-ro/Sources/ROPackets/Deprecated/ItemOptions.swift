//
//  ItemOptions.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import BinaryIO

@available(*, deprecated, message: "Use generated struct instead.")
public struct _ItemOptions: BinaryDecodable, Sendable {
    public var index: Int16
    public var value: Int16
    public var param: UInt8

    public init(from decoder: BinaryDecoder) throws {
        index = try decoder.decode(Int16.self)
        value = try decoder.decode(Int16.self)
        param = try decoder.decode(UInt8.self)
    }
}
