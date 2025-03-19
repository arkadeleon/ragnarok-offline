//
//  RSWRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//

import Metal
import ROCore
import ROShaders

public class RSWRenderer: Renderer {
    public let device: any MTLDevice

    let groundRenderer: GroundRenderer
    let waterRenderer: WaterRenderer
    let modelRenderer: ModelRenderer

    public let camera: Camera

    public init(device: any MTLDevice, ground: Ground, water: Water, models: [Model]) throws {
        self.device = device

        let library = ROCreateShadersLibrary(device)!
        groundRenderer = try GroundRenderer(device: device, library: library, ground: ground)
        waterRenderer = try WaterRenderer(device: device, library: library, water: water)
        modelRenderer = try ModelRenderer(device: device, library: library, models: models)

        camera = Camera()
        camera.defaultDistance = -ground.altitude / 5 + 200
        camera.minimumDistance = camera.defaultDistance - 190
        camera.maximumDistance = camera.defaultDistance + 200
        camera.farZ = 500
    }

    public func render(atTime time: CFTimeInterval, viewport: CGRect, commandBuffer: any MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor) {

//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderPassDescriptor.depthAttachment.clearDepth = 1

        let ground = groundRenderer.ground

        camera.update(size: viewport.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_scale(modelMatrix, [1, -1, 1])
        modelMatrix = matrix_rotate(modelMatrix, radians(90), [1, 0, 0])
        modelMatrix = matrix_translate(modelMatrix, [-Float(ground.width / 2), 0, -Float(ground.height / 2)])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        let normalMatrix = float3x3(modelMatrix).inverse.transpose

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        groundRenderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        waterRenderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )

        modelRenderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        renderCommandEncoder.endEncoding()
    }
}
