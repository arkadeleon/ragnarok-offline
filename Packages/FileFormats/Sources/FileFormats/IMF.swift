//
//  IMF.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/14.
//

import BinaryIO
import Foundation

public struct IMF: FileFormat {
    public var version: Float
    public var checksum: Int32
    public var layers: [IMF.Layer] = []

    public init(from decoder: BinaryDecoder) throws {
        version = try decoder.decode(Float.self)

        checksum = try decoder.decode(Int32.self)

        let layerCount = try decoder.decode(Int32.self) + 1

        for _ in 0..<layerCount {
            let layer = try decoder.decode(IMF.Layer.self)
            layers.append(layer)
        }
    }
}

extension IMF {
    public struct Layer: BinaryDecodable, Sendable {
        public var actions: [IMF.Action] = []

        public init(from decoder: BinaryDecoder) throws {
            let actionCount = try decoder.decode(Int32.self)

            for _ in 0..<actionCount {
                let action = try decoder.decode(IMF.Action.self)
                actions.append(action)
            }
        }
    }
}

extension IMF {
    public struct Action: BinaryDecodable, Sendable {
        public var frames: [IMF.Frame] = []

        public init(from decoder: BinaryDecoder) throws {
            let frameCount = try decoder.decode(Int32.self)

            for _ in 0..<frameCount {
                let frame = try decoder.decode(IMF.Frame.self)
                frames.append(frame)
            }
        }
    }
}

extension IMF {
    public struct Frame: BinaryDecodable, Sendable {
        public var priority: Int32
        public var cx: Int32
        public var cy: Int32

        public init(from decoder: BinaryDecoder) throws {
            priority = try decoder.decode(Int32.self)
            cx = try decoder.decode(Int32.self)
            cy = try decoder.decode(Int32.self)
        }
    }
}

extension IMF {
    public func priority(at indexPath: IndexPath) -> Int32? {
        let layerIndex = indexPath[0]
        let actionIndex = indexPath[1]
        let frameIndex = indexPath[2]

        guard 0..<layers.count ~= layerIndex else {
            return nil
        }

        let layer = layers[layerIndex]
        guard 0..<layer.actions.count ~= actionIndex else {
            return nil
        }

        let action = layer.actions[actionIndex]
        guard 0..<action.frames.count ~= frameIndex else {
            return nil
        }

        let frame = action.frames[frameIndex]
        return frame.priority
    }
}
