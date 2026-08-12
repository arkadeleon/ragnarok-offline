//
//  RSWFilePreviewRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRenderAssets
import RagnarokRendering
import simd

public class RSWFilePreviewRenderer: Renderer {
    public let device: any MTLDevice
    public let configuration: RenderConfiguration

    let groundAsset: GroundRenderAsset
    let worldResource: WorldRenderResource
    let worldRenderer: WorldRenderer

    public let camera: OrbitalCamera

    private var lastModelMatrix = matrix_identity_float4x4
    private var lastCamera: RenderCamera?
    private var lastBounds: CGRect = .zero

    public init(device: any MTLDevice, configuration: RenderConfiguration, worldAsset: WorldAsset) throws {
        self.device = device
        self.configuration = configuration
        self.groundAsset = worldAsset.ground

        worldResource = WorldRenderResource(device: device, asset: worldAsset)
        worldRenderer = try WorldRenderer(device: device, configuration: configuration)

        let defaultDistance = -groundAsset.altitude / 5 + 200
        camera = OrbitalCamera(distance: defaultDistance)
        camera.elevation = .pi / 2
        camera.minimumDistance = defaultDistance - 190
        camera.maximumDistance = defaultDistance + 200
        camera.farZ = 500
    }

    public func focusTile(at screenPoint: CGPoint) {
        guard let tileCenter = tileCenter(at: screenPoint) else {
            return
        }
        camera.animatePan(to: SIMD3<Float>(tileCenter.x, 0, tileCenter.z))
    }

    public func makeCamera(atTime time: TimeInterval, viewport: MTLViewport) -> RenderCamera {
        camera.update(atTime: time)
        camera.update(size: viewport.size)

        return RenderCamera(
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            azimuth: camera.azimuth,
            elevation: camera.elevation
        )
    }

    public func render(frame: RenderFrame) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        modelMatrix = matrix_translate(modelMatrix, [-Float(groundAsset.width / 2), 0, -Float(groundAsset.height / 2)])

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        lastBounds = frame.bounds

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            lastModelMatrix = modelMatrix
            lastCamera = view.camera

            worldRenderer.render(
                resource: worldResource,
                atTime: frame.time,
                modelMatrix: modelMatrix,
                camera: view.camera,
                renderCommandEncoder: renderCommandEncoder
            )

            worldRenderer.renderEffects(
                resource: worldResource,
                atTime: frame.time,
                modelMatrix: modelMatrix,
                camera: view.camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderCommandEncoder.endEncoding()
    }
}

extension RSWFilePreviewRenderer {
    private func tileCenter(at screenPoint: CGPoint) -> SIMD3<Float>? {
        guard let camera = lastCamera,
              let ray = camera.ray(through: screenPoint, in: lastBounds) else {
            return nil
        }

        let inverseModelMatrix = lastModelMatrix.inverse
        let localOrigin4 = inverseModelMatrix * SIMD4<Float>(ray.origin, 1)
        let localDirection4 = inverseModelMatrix * SIMD4<Float>(ray.direction, 0)

        let localOrigin = SIMD3<Float>(localOrigin4.x, localOrigin4.y, localOrigin4.z) / localOrigin4.w
        let localDirection = simd_normalize(SIMD3<Float>(localDirection4.x, localDirection4.y, localDirection4.z))

        guard abs(localDirection.y) > .leastNonzeroMagnitude else {
            return nil
        }

        let distance = -localOrigin.y / localDirection.y
        guard distance >= 0 else {
            return nil
        }

        let localHit = localOrigin + localDirection * distance
        let tileX = Int(floor(localHit.x / 2))
        let tileY = Int(floor(localHit.z / 2))

        guard (0..<groundAsset.width).contains(tileX), (0..<groundAsset.height).contains(tileY) else {
            return nil
        }

        let localCenter = SIMD4<Float>(
            (Float(tileX) + 0.5) * 2,
            0,
            (Float(tileY) + 0.5) * 2,
            1
        )
        let center = lastModelMatrix * localCenter
        return SIMD3<Float>(center.x, center.y, center.z) / center.w
    }
}
