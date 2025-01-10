//
//  ActionsComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/24.
//

import Metal
import MetalKit
import RealityKit
import ROClientResources
import ROCore
import ROFileFormats
import ROGenerated

extension Entity {
    static func loadJob(jobID: JobID) async throws -> Entity {
        async let bodyAsync = loadBody(jobID: jobID)
        async let headAsync = loadHead(hairID: 2)
        async let hpAsync = loadHP()

        let body = try await bodyAsync
        body.position = [0, 1, 0]

        let head = try await headAsync
        head.position = [0, 0.1, 0]
        body.addChild(head)

        let hp = try await hpAsync
        hp.position = [0, -0.4, 0]
        body.addChild(hp)

        return body
    }

    static func loadBody(jobID: JobID) async throws -> Entity {
        let (spr, act) = try await ClientResourceManager.default.bodySpriteFile(sex: .male, jobID: jobID)

        let entity = try await Entity.load(act: act, spr: spr)
        entity.name = "body"

        return entity
    }

    static func loadHead(hairID: Int) async throws -> Entity {
        let (spr, act) = try await ClientResourceManager.default.headSpriteFile(sex: .male, hairID: hairID)

        let entity = try await Entity.load(act: act, spr: spr)
        entity.name = "head"

        return entity
    }

    static func load(act: ACT, spr: SPR) async throws -> Entity {
        let entity = Entity()

        let start = Date()

        let actionsComponent = await ActionsComponent(act: act, spr: spr)
        entity.components.set(actionsComponent)

        let end = Date()
        print("Actions:")
        print(end.timeIntervalSince(start))

        if !actionsComponent.actions.isEmpty {
            entity.runAction(0)
        }

        return entity
    }

    static func loadHP() async throws -> Entity {
        let renderer = GraphicsImageRenderer(size: CGSize(width: 60, height: 5))
        let image = renderer.image { context in
            context.beginPath()
            context.addRect(CGRect(x: 0, y: 0, width: 60, height: 5))
            context.closePath()

            context.setFillColor(#colorLiteral(red: 0.09411764706, green: 0.3882352941, blue: 0.8705882353, alpha: 1).cgColor)
            context.fillPath()
        }

        let entity = try await Entity(image: image!, size: CGSize(width: 60 / 175.0, height: 5 / 175.0))
//        let entity = Entity()
//
//        let texture = try await TextureResource(image: image!, options: TextureResource.CreateOptions(semantic: .color))
//
//        // Create material.
//        var material = PhysicallyBasedMaterial()
//        material.baseColor = .init(texture: .init(texture))
//        material.blending = .transparent(opacity: 1.0)
//        material.opacityThreshold = 0.9999
//
//        // Create model component.
//        let mesh = MeshResource.generatePlane(width: 60 / 175.0, height: 5 / 175.0)
//        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
//        entity.components[ModelComponent.self] = modelComponent

        return entity
    }

    func runAction(_ actionIndex: Int) {
        guard let actionsComponent = components[ActionsComponent.self],
              actionIndex < actionsComponent.actions.count else {
            return
        }

        let action = actionsComponent.actions[actionIndex]

        // Create material.
        var material = PhysicallyBasedMaterial()
        material.blending = .transparent(opacity: 1.0)
        material.opacityThreshold = 0.9999

        // Create texture.
        if let texture = action.texture {
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.textureCoordinateTransform = PhysicallyBasedMaterial.TextureCoordinateTransform(scale: [1 / Float(action.frameCount), 1])
        }

        // Create model component.
        let mesh = MeshResource.generatePlane(width: action.frameWidth / 175, height: action.frameHeight / 175)

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        components.set(modelComponent)

        let frames: [SIMD2<Float>] = (0..<action.frameCount).map { frameIndex in
            [Float(frameIndex) / Float(action.frameCount), 0]
        }
        let bindTarget = BindTarget.material(0).textureCoordinate.offset
        let animationDefinition = SampledAnimation(
            frames: frames,
            name: "action",
            tweenMode: .hold,
            frameInterval: action.frameInterval,
            isAdditive: false,
            bindTarget: bindTarget,
            repeatMode: .repeat
        )

        if let animation = try? AnimationResource.generate(with: animationDefinition) {
            playAnimation(animation)
        }
    }
}

extension Entity {
    convenience init(image cgImage: CGImage, size: CGSize) async throws {
        self.init()

        let options = TextureResource.CreateOptions(semantic: .color)
        let texture = try await TextureResource(image: cgImage, options: options)

        // Create material.
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(texture: .init(texture))
        material.blending = .transparent(opacity: 1.0)
        material.opacityThreshold = 0.9999

        // Create model component.
        let mesh = MeshResource.generatePlane(width: Float(size.width), height: Float(size.height))
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        components[ModelComponent.self] = modelComponent
    }

    convenience init(image cgImage: CGImage, size: CGSize, group: ModelSortGroup, order: Int32) async throws {
        try await self.init(image: cgImage, size: size)

        // Create model sort group component.
        let modelSortGroupComponent = ModelSortGroupComponent(group: group, order: order)
        components[ModelSortGroupComponent.self] = modelSortGroupComponent
    }
}

struct ActionsComponent: Component {
    struct Action {
        var texture: TextureResource?
        var frameWidth: Float
        var frameHeight: Float
        var frameCount: Int
        var frameInterval: Float
    }

    var actions: [Action] = []

    init(act: ACT, spr: SPR) async {
        let imagesBySpriteType = spr.imagesBySpriteType()
        for a in act.actions {
            let spriteAtlas = a.spriteAtlas(using: imagesBySpriteType)

            var action = Action(
                frameWidth: spriteAtlas.frameWidth,
                frameHeight: spriteAtlas.frameHeight,
                frameCount: spriteAtlas.frameCount,
                frameInterval: spriteAtlas.frameInterval
            )

            if let image = spriteAtlas.image,
               let texture = try? await TextureResource(image: image, options: TextureResource.CreateOptions(semantic: .color)) {
                action.texture = texture
            }

            actions.append(action)
        }
    }
}

//class ActionSpriteSystem: System {
//    static let query = EntityQuery(where: .has(ActionsComponent.self) && .has(SpriteComponent.self))
//
//    static var dependencies: [SystemDependency] {
//        [.before(SpriteSystem.self)]
//    }
//
//    required init(scene: Scene) {
//    }
//
//    func update(context: SceneUpdateContext) {
//        let entities = context.scene.performQuery(Self.query)
//
//        for entity in entities {
//            guard let actionSpriteComponent = entity.components[ActionsComponent.self],
//                  var spriteComponent = entity.components[SpriteComponent.self],
//                  let startTime = actionSpriteComponent.actionStartTime
//            else {
//                continue
//            }
//
//            let action = actionSpriteComponent.actions[actionSpriteComponent.actionIndex]
//            let textureIndex = Int(Date.now.timeIntervalSince(startTime) / action.timePerFrame) % action.textures.count
//            let texture = action.textures[textureIndex]
//
//            spriteComponent.sourceTexture = texture
//            entity.components[SpriteComponent.self] = spriteComponent
//        }
//    }
//}
//
//struct SpriteComponent: Component {
//    var sourceTexture: (any MTLTexture)? {
//        didSet {
//            guard let sourceTexture else {
//                return
//            }
//
//            if let drawableQueue = destinationTexture.drawableQueue,
//               drawableQueue.width == sourceTexture.width,
//               drawableQueue.height == sourceTexture.height {
//                return
//            }
//
//            do {
//                let descriptor = TextureResource.DrawableQueue.Descriptor(
//                    pixelFormat: .rgba8Unorm,
//                    width: sourceTexture.width,
//                    height: sourceTexture.height,
//                    usage: [.renderTarget, .shaderRead, .shaderWrite],
//                    mipmapsMode: .none
//                )
//                let drawableQueue = try TextureResource.DrawableQueue(descriptor)
//                destinationTexture.replace(withDrawables: drawableQueue)
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    let destinationTexture: TextureResource
//}
//
//class SpriteSystem: System {
//    static let query = EntityQuery(where: .has(SpriteComponent.self))
//
//    let commandQueue: any MTLCommandQueue
//
//    required init(scene: Scene) {
//        let device = MTLCreateSystemDefaultDevice()!
//        commandQueue = device.makeCommandQueue()!
//    }
//
//    func update(context: SceneUpdateContext) {
//        let entities = context.scene.performQuery(Self.query)
//
//        for entity in entities {
//            guard let spriteComponent = entity.components[SpriteComponent.self] else {
//                continue
//            }
//
//            guard let sourceTexture = spriteComponent.sourceTexture,
//                  let drawable = try? spriteComponent.destinationTexture.drawableQueue?.nextDrawable() else {
//                continue
//            }
//
//            guard let commandBuffer = commandQueue.makeCommandBuffer(),
//                  let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else {
//                continue
//            }
//
//            blitCommandEncoder.copy(from: sourceTexture, to: drawable.texture)
//            blitCommandEncoder.endEncoding()
//
//            commandBuffer.present(drawable)
//            commandBuffer.commit()
//        }
//    }
//}
