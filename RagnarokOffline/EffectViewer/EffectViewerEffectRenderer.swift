//
//  EffectViewerEffectRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import CoreGraphics
import Foundation
import Metal
import QuartzCore
import RagnarokCore
import RagnarokFileFormats
import RagnarokRenderAssets
import RagnarokRendering
import simd

class EffectViewerEffectRenderer: Renderer {
    let device: any MTLDevice
    let configuration: RenderConfiguration

    private let effectRenderer: EffectRenderer
    private let effectResourceGroup: EffectRenderResourceGroup

    let camera: OrbitalCamera

    init(device: any MTLDevice, configuration: RenderConfiguration, assetGroup: EffectAssetGroup) throws {
        self.device = device
        self.configuration = configuration

        effectRenderer = try EffectRenderer(device: device, configuration: configuration)
        effectResourceGroup = EffectRenderResourceGroup(
            device: device,
            assetGroup: assetGroup,
            creationTime: CACurrentMediaTime(),
            delay: 0
        )

        camera = OrbitalCamera(distance: 20)
        camera.fovy = 45
        camera.nearZ = 1
        camera.farZ = 1000
        camera.elevation = radians(20)
        camera.minimumDistance = 8
        camera.maximumDistance = 80
        camera.target = [0, 1.5, 0]
    }

    func makeCamera(atTime time: TimeInterval, viewport: MTLViewport) -> RenderCamera {
        camera.update(atTime: time)
        camera.update(size: viewport.size)

        return RenderCamera(
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            azimuth: camera.azimuth,
            elevation: camera.elevation
        )
    }

    func render(frame: RenderFrame) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            effectRenderer.render(
                resourceGroup: effectResourceGroup,
                atTime: frame.time,
                modelMatrix: modelMatrix,
                camera: view.camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderCommandEncoder.endEncoding()
    }

    func isComplete(atTime time: TimeInterval) -> Bool {
        effectResourceGroup.isExpired(atTime: time)
    }
}
