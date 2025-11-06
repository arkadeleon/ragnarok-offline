//
//  Backport.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/11/6.
//

import CoreGraphics
import RealityKit

struct Backport<T> {
}

extension Backport where T: MeshResource {
    static func generate(from descriptors: sending [MeshDescriptor]) async throws -> MeshResource {
        if #available(macOS 15.0, iOS 18.0, *) {
            try await MeshResource(from: descriptors)
        } else {
            try await MeshResource.generate(from: descriptors)
        }
    }
}

extension Backport where T: TextureResource {
    static func generate(from cgImage: CGImage, withName resourceName: String? = nil, options: TextureResource.CreateOptions) async throws -> TextureResource {
        if #available(macOS 15.0, iOS 18.0, visionOS 2.0, *) {
            try await TextureResource(
                image: cgImage,
                withName: resourceName,
                options: TextureResource.CreateOptions(semantic: .color)
            )
        } else {
            try await TextureResource.generate(
                from: cgImage,
                withName: resourceName,
                options: TextureResource.CreateOptions(semantic: .color)
            )
        }
    }
}
