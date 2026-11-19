//
//  RenderQueue.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/11/19.
//

import simd

public enum RenderPassBucket: Int, CaseIterable, Comparable, Sendable {
    case opaque = 0
    case groundDecal = 1
    case translucent = 2
    case overlay = 3

    public static func < (lhs: RenderPassBucket, rhs: RenderPassBucket) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct RenderTranslucentPasses: OptionSet, Sendable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let all: RenderTranslucentPasses = [.behindWater, .inFrontOfWater]
    public static let behindWater = RenderTranslucentPasses(rawValue: 1 << 0)
    public static let inFrontOfWater = RenderTranslucentPasses(rawValue: 1 << 1)
}

public struct RenderQueueItem<Payload> {
    public let bucket: RenderPassBucket
    public let translucentPasses: RenderTranslucentPasses
    public let worldCenter: SIMD3<Float>
    public let modelMatrix: simd_float4x4
    public let sequence: Int
    public internal(set) var sortDepth: Float
    public let payload: Payload
}

public final class RenderQueue<Payload> {
    private var opaqueItems: [RenderQueueItem<Payload>] = []
    private var groundDecalItems: [RenderQueueItem<Payload>] = []
    private var translucentItems: [RenderQueueItem<Payload>] = []
    private var overlayItems: [RenderQueueItem<Payload>] = []
    private var nextSequence = 0

    public init() {
    }

    public func removeAll(keepingCapacity: Bool = true) {
        opaqueItems.removeAll(keepingCapacity: keepingCapacity)
        groundDecalItems.removeAll(keepingCapacity: keepingCapacity)
        translucentItems.removeAll(keepingCapacity: keepingCapacity)
        overlayItems.removeAll(keepingCapacity: keepingCapacity)
        nextSequence = 0
    }

    public func submit(
        bucket: RenderPassBucket,
        translucentPasses: RenderTranslucentPasses = .inFrontOfWater,
        worldCenter: SIMD3<Float> = .zero,
        modelMatrix: simd_float4x4 = matrix_identity_float4x4,
        payload: Payload
    ) {
        let item = RenderQueueItem(
            bucket: bucket,
            translucentPasses: translucentPasses,
            worldCenter: worldCenter,
            modelMatrix: modelMatrix,
            sequence: nextSequence,
            sortDepth: 0,
            payload: payload
        )
        nextSequence += 1

        switch bucket {
        case .opaque:
            opaqueItems.append(item)
        case .groundDecal:
            groundDecalItems.append(item)
        case .translucent:
            translucentItems.append(item)
        case .overlay:
            overlayItems.append(item)
        }
    }

    public func sort(camera: RenderCamera) {
        for index in translucentItems.indices {
            let item = translucentItems[index]
            let viewPosition = camera.viewMatrix * item.modelMatrix * SIMD4<Float>(item.worldCenter, 1)
            translucentItems[index].sortDepth = -viewPosition.z
        }

        translucentItems.sort { lhs, rhs in
            if lhs.sortDepth == rhs.sortDepth {
                lhs.sequence < rhs.sequence
            } else {
                lhs.sortDepth > rhs.sortDepth
            }
        }
    }

    public func items(in bucket: RenderPassBucket) -> [RenderQueueItem<Payload>] {
        switch bucket {
        case .opaque:
            opaqueItems
        case .groundDecal:
            groundDecalItems
        case .translucent:
            translucentItems
        case .overlay:
            overlayItems
        }
    }
}
