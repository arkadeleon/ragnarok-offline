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

    private struct SpriteCacheKey: Hashable {
        let spritePath: String
        let actionPath: String
    }

    private struct SendableTexture: @unchecked Sendable {
        let texture: any MTLTexture
    }

    private enum Phase<Value> {
        case inProgress(Task<Value?, Never>)
        case loaded(Value)
        case failed
    }

    public let device: any MTLDevice
    public let resourceManager: ResourceManager

    private var strAssets: [STRCacheKey : EffectAssetStore.Phase<STREffectAsset>] = [:]
    private var spriteAssets: [SpriteCacheKey : EffectAssetStore.Phase<EffectSpriteAsset>] = [:]
    private var textures: [String : EffectAssetStore.Phase<SendableTexture>] = [:]

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

    public func texture(atPath path: String) -> (any MTLTexture)? {
        let key = Self.normalizedTextureKey(forPath: path)
        switch textures[key] {
        case .loaded(let wrapped):
            return wrapped.texture
        case .inProgress, .failed:
            return nil
        case nil:
            _ = startTextureLoad(forPath: path, key: key)
            return nil
        }
    }

    @discardableResult
    public func preloadTexture(atPath path: String) async -> (any MTLTexture)? {
        let key = Self.normalizedTextureKey(forPath: path)
        switch textures[key] {
        case .loaded(let wrapped):
            return wrapped.texture
        case .failed:
            return nil
        case .inProgress(let task):
            return await task.value?.texture
        case nil:
            return await startTextureLoad(forPath: path, key: key).value?.texture
        }
    }

    public func hasFailedTexture(atPath path: String) -> Bool {
        let key = Self.normalizedTextureKey(forPath: path)
        if case .failed = textures[key] {
            return true
        }
        return false
    }

    public func spriteAsset(spritePath: String, actionPath: String) -> EffectSpriteAsset? {
        let key = SpriteCacheKey(
            spritePath: Self.normalizedTextureKey(forPath: spritePath),
            actionPath: Self.normalizedTextureKey(forPath: actionPath)
        )
        switch spriteAssets[key] {
        case .loaded(let asset):
            return asset
        case .inProgress, .failed:
            return nil
        case nil:
            _ = startSpriteLoad(spritePath: spritePath, actionPath: actionPath, key: key)
            return nil
        }
    }

    @discardableResult
    public func preloadSpriteAsset(spritePath: String, actionPath: String) async -> EffectSpriteAsset? {
        let key = SpriteCacheKey(
            spritePath: Self.normalizedTextureKey(forPath: spritePath),
            actionPath: Self.normalizedTextureKey(forPath: actionPath)
        )
        switch spriteAssets[key] {
        case .loaded(let asset):
            return asset
        case .failed:
            return nil
        case .inProgress(let task):
            return await task.value
        case nil:
            return await startSpriteLoad(spritePath: spritePath, actionPath: actionPath, key: key).value
        }
    }

    public func removeAll() {
        for phase in strAssets.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }
        strAssets.removeAll()

        for phase in spriteAssets.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }
        spriteAssets.removeAll()

        for phase in textures.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }
        textures.removeAll()
    }

    private static func normalizedTextureKey(forPath path: String) -> String {
        path.replacingOccurrences(of: "\\", with: "/").lowercased()
    }

    private func startTextureLoad(forPath path: String, key: String) -> Task<SendableTexture?, Never> {
        let device = self.device
        let resourceManager = self.resourceManager

        let task = Task<SendableTexture?, Never> { [weak self] in
            let wrapped = await Self.loadTexture(
                atPath: path,
                device: device,
                resourceManager: resourceManager
            )
            guard let self, !Task.isCancelled else {
                return nil
            }
            if let wrapped {
                self.textures[key] = .loaded(wrapped)
            } else {
                self.textures[key] = .failed
            }
            return wrapped
        }

        textures[key] = .inProgress(task)
        return task
    }

    private nonisolated static func loadTexture(
        atPath path: String,
        device: any MTLDevice,
        resourceManager: ResourceManager
    ) async -> SendableTexture? {
        let normalizedPath = path.replacingOccurrences(of: "\\", with: "/")
        let texturePath = ResourcePath.textureDirectory.appending(subpath: normalizedPath)
        let removesMagentaPixels = normalizedPath.lowercased().hasSuffix(".bmp")
        guard let image = try? await resourceManager.image(
            at: texturePath,
            removesMagentaPixels: removesMagentaPixels
        ), !Task.isCancelled else {
            return nil
        }
        let straightImage = image.cgImage.unpremultiplyingAlpha() ?? image.cgImage
        guard let texture = MetalTextureFactory.makeTexture(from: straightImage, device: device, label: normalizedPath) else {
            return nil
        }
        return SendableTexture(texture: texture)
    }

    private func startSpriteLoad(
        spritePath: String,
        actionPath: String,
        key: SpriteCacheKey
    ) -> Task<EffectSpriteAsset?, Never> {
        let device = self.device
        let resourceManager = self.resourceManager

        let task = Task<EffectSpriteAsset?, Never> { [weak self] in
            let asset = await Self.loadSpriteAsset(
                spritePath: spritePath,
                actionPath: actionPath,
                device: device,
                resourceManager: resourceManager
            )
            guard let self, !Task.isCancelled else {
                return nil
            }
            if let asset {
                self.spriteAssets[key] = .loaded(asset)
            } else {
                self.spriteAssets[key] = .failed
            }
            return asset
        }

        spriteAssets[key] = .inProgress(task)
        return task
    }

    private nonisolated static func loadSpriteAsset(
        spritePath: String,
        actionPath: String,
        device: any MTLDevice,
        resourceManager: ResourceManager
    ) async -> EffectSpriteAsset? {
        let normalizedSprite = spritePath.replacingOccurrences(of: "\\", with: "/")
        let normalizedAction = actionPath.replacingOccurrences(of: "\\", with: "/")
        let sprResourcePath = ResourcePath.spriteDirectory.appending(subpath: normalizedSprite)
        let actResourcePath = ResourcePath.spriteDirectory.appending(subpath: normalizedAction)

        guard let sprData = try? await resourceManager.contentsOfResource(at: sprResourcePath),
              !Task.isCancelled,
              let actData = try? await resourceManager.contentsOfResource(at: actResourcePath),
              !Task.isCancelled,
              let spr = try? SPR(data: sprData),
              let act = try? ACT(data: actData) else {
            return nil
        }

        let imagesByType = spr.imagesBySpriteType()

        func convert(_ cgImages: [CGImage?], prefix: String) -> [EffectSpriteAsset.SpriteImage?] {
            cgImages.enumerated().map { index, cgImage in
                guard let cgImage else {
                    return nil
                }
                let straightImage = cgImage.unpremultiplyingAlpha() ?? cgImage
                guard let texture = MetalTextureFactory.makeTexture(
                    from: straightImage,
                    device: device,
                    label: "\(normalizedSprite)[\(prefix):\(index)]"
                ) else {
                    return nil
                }
                return EffectSpriteAsset.SpriteImage(
                    texture: texture,
                    width: straightImage.width,
                    height: straightImage.height
                )
            }
        }

        let indexed = convert(imagesByType[.indexed] ?? [], prefix: "idx")
        let rgba = convert(imagesByType[.rgba] ?? [], prefix: "rgba")
        return EffectSpriteAsset(act: act, indexedSprites: indexed, rgbaSprites: rgba)
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
