//
//  MapRuntimeRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import Metal
import RagnarokRenderers

final class MapRuntimeRenderer: Renderer {
    let device: any MTLDevice

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device
    }

    func render(
        atTime time: CFTimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        encoder.endEncoding()
    }
}

#endif
