//
//  ComposedSprite.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/4/29.
//

import RagnarokFileFormats
import RagnarokResources
import simd

final public class ComposedSprite: Sendable {
    public let configuration: ComposedSprite.Configuration
    let resourceManager: ResourceManager

    public let parts: [ComposedSprite.Part]
    public let imf: IMF?

    var mainPart: ComposedSprite.Part? {
        parts.first {
            $0.semantic == .main || $0.semantic == .playerBody
        }
    }

    public init(configuration: ComposedSprite.Configuration, resourceManager: ResourceManager) async throws {
        self.configuration = configuration
        self.resourceManager = resourceManager

        let composer = ComposedSprite.Composer(configuration: configuration, resourceManager: resourceManager)

        if configuration.job.isPlayer {
            parts = try await composer.composePlayerSprite()

            let scriptContext = await resourceManager.scriptContext()
            let pathGenerator = SpritePathGenerator(scriptContext: scriptContext)

            if let imfPath = pathGenerator.generateIMFPath(job: configuration.job, gender: configuration.gender) {
                let imfPath = imfPath.appendingPathExtension("imf")
                let imfData = try await resourceManager.contentsOfResource(at: imfPath)
                imf = try IMF(data: imfData)
            } else {
                imf = nil
            }
        } else {
            parts = try await composer.composeNonPlayerSprite()

            imf = nil
        }
    }

    public init(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager,
        parts: [ComposedSprite.Part],
        imf: IMF? = nil
    ) {
        self.configuration = configuration
        self.resourceManager = resourceManager
        self.parts = parts
        self.imf = imf
    }
}

extension ComposedSprite {
    public struct Part: Sendable {
        public enum Semantic: Sendable {
            case main
            case playerBody
            case playerHead
            case weapon
            case shield
            case headgear
            case garment
            case shadow
        }

        public var sprite: SpriteResource
        public var semantic: ComposedSprite.Part.Semantic
        public var orderBySemantic = 0

        public var parent: SpriteResource?

        public var scaleFactor: Double = 1

        public init(sprite: SpriteResource, semantic: ComposedSprite.Part.Semantic, orderBySemantic: Int = 0) {
            self.sprite = sprite
            self.semantic = semantic
            self.orderBySemantic = orderBySemantic
        }

        public func frameRange(
            action: ACT.Action,
            actionType: CharacterActionType,
            headDirection: CharacterHeadDirection
        ) -> Range<Int> {
            guard !action.frames.isEmpty else {
                return 0..<0
            }

            var startFrameIndex = action.frames.startIndex
            var endFrameIndex = action.frames.endIndex

            if actionType == .idle || actionType == .sit {
                switch semantic {
                case .playerBody:
                    let frameIndex = min(headDirection.rawValue, action.frames.count - 1)
                    startFrameIndex = frameIndex
                    endFrameIndex = frameIndex + 1
                case .playerHead, .headgear:
                    let frameCount = action.frames.count / 3
                    guard frameCount > 0 else {
                        return 0..<0
                    }
                    startFrameIndex = min(headDirection.rawValue * frameCount, action.frames.count - frameCount)
                    endFrameIndex = min(startFrameIndex + frameCount, action.frames.count)
                default:
                    break
                }
            }

            return startFrameIndex..<endFrameIndex
        }

        public func parentOffset(
            actionType: CharacterActionType,
            action: ACT.Action,
            actionIndex: Int,
            absoluteFrameIndex: Int,
            frame: ACT.Frame
        ) -> SIMD2<Int32> {
            guard let parent else {
                return .zero
            }

            var offset: SIMD2<Int32> = .zero
            var parentFrameIndex = absoluteFrameIndex

            if semantic == .headgear && (actionType == .idle || actionType == .sit) {
                let frameCount = action.frames.count / 3
                if frameCount > 0 {
                    parentFrameIndex = absoluteFrameIndex / frameCount
                }
            }

            if let parentFrame = parent.act.frame(at: [actionIndex, parentFrameIndex]),
               let parentAnchorPoint = parentFrame.anchorPoints.first {
                offset = [parentAnchorPoint.x, parentAnchorPoint.y]
            }

            if let anchorPoint = frame.anchorPoints.first {
                offset &-= [anchorPoint.x, anchorPoint.y]
            }

            return offset
        }
    }
}

extension ComposedSprite {
    public func zIndex(
        for part: ComposedSprite.Part,
        direction: CharacterDirection,
        actionIndex: Int,
        frameIndex: Int,
        scriptContext: ScriptContext?
    ) -> Int {
        if part.semantic == .shadow {
            return -1
        }

        let isNorth = switch direction {
        case .west, .northwest, .north, .northeast: true
        case .south, .southwest, .east, .southeast: false
        }

        let zIndexForGarment: () -> Int = { [configuration] in
            guard let scriptContext else {
                return 5
            }
            let drawOnTop = scriptContext.drawOnTop(
                forRobeID: configuration.garment,
                genderID: configuration.gender.rawValue,
                jobID: configuration.job.rawValue,
                actionIndex: actionIndex,
                frameIndex: frameIndex
            )
            if drawOnTop {
                return scriptContext.isTopLayer(forRobeID: configuration.garment) ? 25 : (isNorth ? 16 : 11)
            } else {
                return 5
            }
        }

        if isNorth {
            switch part.semantic {
            case .playerBody:
                return 15
            case .playerHead:
                if let imf, let priority = imf.priority(at: [1, actionIndex, frameIndex]), priority == 1 {
                    return 14
                } else {
                    return 20
                }
            case .weapon:
                return 30 - (2 - part.orderBySemantic)
            case .shield:
                return 10
            case .headgear:
                return 25 - (3 - part.orderBySemantic)
            case .garment:
                return zIndexForGarment()
            default:
                return 0
            }
        } else {
            switch part.semantic {
            case .playerBody:
                return 10
            case .playerHead:
                if let imf, let priority = imf.priority(at: [1, actionIndex, frameIndex]), priority == 1 {
                    return 9
                } else {
                    return 15
                }
            case .weapon:
                return 25 - (2 - part.orderBySemantic)
            case .shield:
                return 30
            case .headgear:
                return 20 - (3 - part.orderBySemantic)
            case .garment:
                return zIndexForGarment()
            default:
                return 0
            }
        }
    }
}
