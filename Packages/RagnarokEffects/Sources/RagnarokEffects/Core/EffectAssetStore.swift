//
//  EffectAssetStore.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import CoreGraphics
import Metal
import RagnarokCore
import RagnarokFileFormats
import RagnarokRendering
import RagnarokResources

public struct STREffectAsset: @unchecked Sendable {
    public let animation: STREffectAnimation
    public let textures: [String : any MTLTexture]

    public init(animation: STREffectAnimation, textures: [String : any MTLTexture]) {
        self.animation = animation
        self.textures = textures
    }
}

@MainActor
public final class EffectAssetStore {
    private enum Phase<Value> {
        case inProgress(Task<Value?, Never>)
        case loaded(Value)
        case failed
    }

    public let device: any MTLDevice
    public let resourceManager: ResourceManager
    public let pathResolver: EffectResourcePathResolver

    private var strAssets: [String : EffectAssetStore.Phase<STREffectAsset>] = [:]

    public init(
        device: any MTLDevice,
        resourceManager: ResourceManager,
        pathResolver: EffectResourcePathResolver = EffectResourcePathResolver()
    ) {
        self.device = device
        self.resourceManager = resourceManager
        self.pathResolver = pathResolver
    }

    public func strAsset(atPath path: String) -> STREffectAsset? {
        let resolvedPath = pathResolver.resolveSTRPath(path)
        switch strAssets[resolvedPath] {
        case .loaded(let asset):
            return asset
        case .inProgress, .failed:
            return nil
        case nil:
            _ = startSTRLoad(resolvedPath: resolvedPath)
            return nil
        }
    }

    @discardableResult
    public func preloadSTRAsset(atPath path: String) async -> STREffectAsset? {
        let resolvedPath = pathResolver.resolveSTRPath(path)
        switch strAssets[resolvedPath] {
        case .loaded(let asset):
            return asset
        case .failed:
            return nil
        case .inProgress(let task):
            return await task.value
        case nil:
            return await startSTRLoad(resolvedPath: resolvedPath).value
        }
    }

    public func hasFailedSTRAsset(atPath path: String) -> Bool {
        let resolvedPath = pathResolver.resolveSTRPath(path)
        if case .failed = strAssets[resolvedPath] {
            return true
        }
        return false
    }

    public func removeAll() {
        for phase in strAssets.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }
        strAssets.removeAll()
    }

    private func startSTRLoad(resolvedPath: String) -> Task<STREffectAsset?, Never> {
        let device = self.device
        let resourceManager = self.resourceManager

        let task = Task<STREffectAsset?, Never> { [weak self] in
            let asset = await Self.loadSTRAsset(
                resolvedPath: resolvedPath,
                device: device,
                resourceManager: resourceManager
            )
            guard let self, !Task.isCancelled else {
                return nil
            }
            if let asset {
                self.strAssets[resolvedPath] = .loaded(asset)
            } else {
                self.strAssets[resolvedPath] = .failed
            }
            return asset
        }

        strAssets[resolvedPath] = .inProgress(task)
        return task
    }

    private nonisolated static func loadSTRAsset(
        resolvedPath: String,
        device: any MTLDevice,
        resourceManager: ResourceManager
    ) async -> STREffectAsset? {
        let strPath = ResourcePath.effectDirectory.appending(subpath: resolvedPath)
        guard !Task.isCancelled,
              let strData = try? await resourceManager.contentsOfResource(at: strPath),
              !Task.isCancelled,
              let str = try? STR(data: strData) else {
            return nil
        }

        var textureImages: [String : CGImage] = [:]
        var textures: [String : any MTLTexture] = [:]
        for textureName in Set(str.layers.flatMap(\.textures)) {
            guard !Task.isCancelled else {
                return nil
            }
            let fileName = textureName.contains(".") ? textureName : "\(textureName).bmp"
            let texturePath = strPath.removingLastComponent().appending(subpath: fileName)
            let removesMagentaPixels = fileName.lowercased().hasSuffix(".bmp")
            if let image = try? await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels) {
                let straightImage = image.cgImage.unpremultiplyingAlpha() ?? image.cgImage
                textureImages[textureName] = straightImage
                if let texture = MetalTextureFactory.makeTexture(from: straightImage, device: device, label: textureName) {
                    textures[textureName] = texture
                }
            }
        }

        guard !Task.isCancelled else {
            return nil
        }

        let animation = STREffectAnimation(str: str, textureImages: textureImages)
        return STREffectAsset(animation: animation, textures: textures)
    }
}
