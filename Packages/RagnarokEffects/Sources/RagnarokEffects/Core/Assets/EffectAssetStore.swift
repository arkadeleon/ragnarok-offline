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

@MainActor
public final class EffectAssetStore {
    private struct STRCacheKey: Hashable {
        let path: String
        let usesMinimalEffects: Bool
    }

    private enum Phase<Value> {
        case inProgress(Task<Value?, Never>)
        case loaded(Value)
        case failed
    }

    public let device: any MTLDevice
    public let resourceManager: ResourceManager

    private var strAssets: [STRCacheKey : EffectAssetStore.Phase<STREffectAsset>] = [:]

    public init(device: any MTLDevice, resourceManager: ResourceManager) {
        self.device = device
        self.resourceManager = resourceManager
    }

    public func strAsset(atPath path: String, usesMinimalEffects: Bool = false) -> STREffectAsset? {
        let key = STRCacheKey(path: path, usesMinimalEffects: usesMinimalEffects)
        switch strAssets[key] {
        case .loaded(let asset):
            return asset
        case .inProgress, .failed:
            return nil
        case nil:
            _ = startSTRLoad(for: key)
            return nil
        }
    }

    @discardableResult
    public func preloadSTRAsset(atPath path: String, usesMinimalEffects: Bool = false) async -> STREffectAsset? {
        let key = STRCacheKey(path: path, usesMinimalEffects: usesMinimalEffects)
        switch strAssets[key] {
        case .loaded(let asset):
            return asset
        case .failed:
            return nil
        case .inProgress(let task):
            return await task.value
        case nil:
            return await startSTRLoad(for: key).value
        }
    }

    public func hasFailedSTRAsset(atPath path: String, usesMinimalEffects: Bool = false) -> Bool {
        let key = STRCacheKey(path: path, usesMinimalEffects: usesMinimalEffects)
        if case .failed = strAssets[key] {
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

    private func startSTRLoad(for key: STRCacheKey) -> Task<STREffectAsset?, Never> {
        let resolver = EffectResourcePathResolver(usesMinimalEffects: key.usesMinimalEffects)
        let candidatePaths = resolver.candidateSTRPaths(forPath: key.path)

        let device = self.device
        let resourceManager = self.resourceManager

        let task = Task<STREffectAsset?, Never> { [weak self] in
            let asset = await Self.loadSTRAsset(
                candidatePaths: candidatePaths,
                device: device,
                resourceManager: resourceManager
            )
            guard let self, !Task.isCancelled else {
                return nil
            }
            if let asset {
                self.strAssets[key] = .loaded(asset)
            } else {
                self.strAssets[key] = .failed
            }
            return asset
        }

        strAssets[key] = .inProgress(task)
        return task
    }

    private nonisolated static func loadSTRAsset(
        candidatePaths: [String],
        device: any MTLDevice,
        resourceManager: ResourceManager
    ) async -> STREffectAsset? {
        var loaded: (strPath: ResourcePath, str: STR)?
        for candidate in candidatePaths {
            guard !Task.isCancelled else {
                return nil
            }
            let candidatePath = ResourcePath.effectDirectory.appending(subpath: candidate)
            if let strData = try? await resourceManager.contentsOfResource(at: candidatePath),
               !Task.isCancelled,
               let str = try? STR(data: strData) {
                loaded = (candidatePath, str)
                break
            }
        }

        guard let (strPath, str) = loaded, !Task.isCancelled else {
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
