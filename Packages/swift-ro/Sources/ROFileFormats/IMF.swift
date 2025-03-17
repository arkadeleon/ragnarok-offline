//
//  IMF.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/14.
//

import Foundation
import ROCore

public struct IMF: BinaryDecodable, Sendable {
    public let version: Float
    public let checksum: Int32
    public let layers: [IMF.Layer]

    public init(data: Data) throws {
        let decoder = BinaryDecoder(data: data)
        self = try decoder.decode(IMF.self)
    }

    public init(from decoder: BinaryDecoder) throws {
        version = try decoder.decode(Float.self)

        checksum = try decoder.decode(Int32.self)

        let layerCount = try decoder.decode(Int32.self) + 1

        layers = try (0..<layerCount).map { _ in
            try decoder.decode(IMF.Layer.self)
        }
    }
}

extension IMF {
    public struct Layer: BinaryDecodable, Sendable {
        public let actions: [IMF.Action]

        public init(from decoder: BinaryDecoder) throws {
            let actionCount = try decoder.decode(Int32.self)

            actions = try (0..<actionCount).map { _ in
                try decoder.decode(IMF.Action.self)
            }
        }
    }
}

extension IMF {
    public struct Action: BinaryDecodable, Sendable {
        public let frames: [IMF.Frame]

        public init(from decoder: BinaryDecoder) throws {
            let frameCount = try decoder.decode(Int32.self)

            frames = try (0..<frameCount).map { _ in
                try decoder.decode(IMF.Frame.self)
            }
        }
    }
}

extension IMF {
    public struct Frame: BinaryDecodable, Sendable {
        public let priority: Int32
        public let cx: Int32
        public let cy: Int32

        public init(from decoder: BinaryDecoder) throws {
            priority = try decoder.decode(Int32.self)
            cx = try decoder.decode(Int32.self)
            cy = try decoder.decode(Int32.self)
        }
    }
}
