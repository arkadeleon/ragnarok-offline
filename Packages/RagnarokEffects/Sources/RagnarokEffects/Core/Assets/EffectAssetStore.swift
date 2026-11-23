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
        switch strAssets[path] {
        case .loaded(let asset):
            return asset
        case .inProgress, .failed:
            return nil
        case nil:
            _ = startSTRLoad(forPath: path)
            return nil
        }
    }

    @discardableResult
    public func preloadSTRAsset(atPath path: String) async -> STREffectAsset? {
        switch strAssets[path] {
        case .loaded(let asset):
            return asset
        case .failed:
            return nil
        case .inProgress(let task):
            return await task.value
        case nil:
            return await startSTRLoad(forPath: path).value
        }
    }

    public func hasFailedSTRAsset(atPath path: String) -> Bool {
        if case .failed = strAssets[path] {
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

    private func startSTRLoad(forPath path: String) -> Task<STREffectAsset?, Never> {
        let candidatePaths = pathResolver.candidateSTRPaths(forPath: path)

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
                self.strAssets[path] = .loaded(asset)
            } else {
                self.strAssets[path] = .failed
            }
            return asset
        }

        strAssets[path] = .inProgress(task)
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
