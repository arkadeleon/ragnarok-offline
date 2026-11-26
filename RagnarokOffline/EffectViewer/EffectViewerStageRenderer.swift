//
//  EffectViewerStageRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/26.
//

import Metal
import RagnarokRendering
import simd

@MainActor
final class EffectViewerStageRenderer {
    static let centerCharcoalColor = SIMD3<Float>(0.118, 0.133, 0.169)
    static let edgeCharcoalColor = SIMD3<Float>(0.067, 0.075, 0.094)

    private struct BackdropUniforms {
        var centerColor: SIMD3<Float>
        var _pad0: Float = 0
        var edgeColor: SIMD3<Float>
        var _pad1: Float = 0
    }

    private struct GridUniforms {
        var viewProjectionMatrix: simd_float4x4
    }

    private static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;

    struct BackdropUniforms {
        float3 centerColor;
        float _pad0;
        float3 edgeColor;
        float _pad1;
    };

    struct BackdropOut {
        float4 position [[position]];
        float2 ndc;
    };

    vertex BackdropOut effectViewerBackdropVertex(uint vertexID [[vertex_id]]) {
        float2 positions[3] = {
            float2(-1.0, -1.0),
            float2( 3.0, -1.0),
            float2(-1.0,  3.0)
        };
        BackdropOut out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        out.ndc = positions[vertexID];
        return out;
    }

    fragment float4 effectViewerBackdropFragment(
        BackdropOut in [[stage_in]],
        constant BackdropUniforms &uniforms [[buffer(0)]]
    ) {
        float t = smoothstep(0.0, 1.2, length(in.ndc));
        float3 color = mix(uniforms.centerColor, uniforms.edgeColor, t);
        return float4(color, 1.0);
    }

    struct GridUniforms {
        float4x4 viewProjectionMatrix;
    };

    struct GridOut {
        float4 position [[position]];
        float2 worldXZ;
    };

    vertex GridOut effectViewerGridVertex(
        uint vertexID [[vertex_id]],
        constant GridUniforms &uniforms [[buffer(0)]]
    ) {
        float2 corners[4] = {
            float2(-32.0, -32.0),
            float2( 32.0, -32.0),
            float2(-32.0,  32.0),
            float2( 32.0,  32.0)
        };
        float2 xz = corners[vertexID];
        GridOut out;
        out.position = uniforms.viewProjectionMatrix * float4(xz.x, 0.0, xz.y, 1.0);
        out.worldXZ = xz;
        return out;
    }

    fragment float4 effectViewerGridFragment(GridOut in [[stage_in]]) {
        float2 coord = in.worldXZ;
        float2 minorDeriv = fwidth(coord);
        float2 minorGrid = abs(fract(coord - 0.5) - 0.5) / max(minorDeriv, float2(1e-4));
        float minorLine = 1.0 - min(min(minorGrid.x, minorGrid.y), 1.0);

        float2 majorCoord = coord / 5.0;
        float2 majorDeriv = fwidth(majorCoord);
        float2 majorGrid = abs(fract(majorCoord - 0.5) - 0.5) / max(majorDeriv, float2(1e-4));
        float majorLine = 1.0 - min(min(majorGrid.x, majorGrid.y), 1.0);

        float axisX = 1.0 - min(abs(coord.y) / max(minorDeriv.y, 1e-4), 1.0);
        float axisZ = 1.0 - min(abs(coord.x) / max(minorDeriv.x, 1e-4), 1.0);
        float axisLine = max(axisX, axisZ);

        float dist = length(coord);
        float fade = 1.0 - smoothstep(12.0, 28.0, dist);

        float alpha = max(minorLine * 0.12, majorLine * 0.24);
        alpha = max(alpha, axisLine * 0.30);
        alpha *= fade;

        if (alpha <= 0.001) {
            discard_fragment();
        }

        float3 color = float3(0.72, 0.76, 0.84);
        if (axisX > axisZ && axisX > 0.1) {
            color = mix(color, float3(0.75, 0.40, 0.42), 0.45);
        } else if (axisZ > 0.1) {
            color = mix(color, float3(0.42, 0.58, 0.80), 0.45);
        }

        return float4(color, alpha);
    }
    """

    private let backdropPipelineState: any MTLRenderPipelineState
    private let backdropDepthStencilState: any MTLDepthStencilState
    private let gridPipelineState: any MTLRenderPipelineState
    private let gridDepthStencilState: any MTLDepthStencilState

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        let library = try device.makeLibrary(source: Self.shaderSource, options: nil)

        let backdropDescriptor = MTLRenderPipelineDescriptor()
        backdropDescriptor.vertexFunction = library.makeFunction(name: "effectViewerBackdropVertex")
        backdropDescriptor.fragmentFunction = library.makeFunction(name: "effectViewerBackdropFragment")
        backdropDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        backdropDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        backdropDescriptor.colorAttachments[0].isBlendingEnabled = false
        backdropDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        backdropPipelineState = try device.makeRenderPipelineState(descriptor: backdropDescriptor)

        let backdropDepthDescriptor = MTLDepthStencilDescriptor()
        backdropDepthDescriptor.depthCompareFunction = .always
        backdropDepthDescriptor.isDepthWriteEnabled = false
        backdropDepthStencilState = device.makeDepthStencilState(descriptor: backdropDepthDescriptor)!

        let gridDescriptor = MTLRenderPipelineDescriptor()
        gridDescriptor.vertexFunction = library.makeFunction(name: "effectViewerGridVertex")
        gridDescriptor.fragmentFunction = library.makeFunction(name: "effectViewerGridFragment")
        gridDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        gridDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        gridDescriptor.colorAttachments[0].isBlendingEnabled = true
        gridDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        gridDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        gridDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        gridDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        gridDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        gridPipelineState = try device.makeRenderPipelineState(descriptor: gridDescriptor)

        let gridDepthDescriptor = MTLDepthStencilDescriptor()
        gridDepthDescriptor.depthCompareFunction = configuration.depthCompareFunction
        gridDepthDescriptor.isDepthWriteEnabled = false
        gridDepthStencilState = device.makeDepthStencilState(descriptor: gridDepthDescriptor)!
    }

    func renderBackdrop(renderCommandEncoder: any MTLRenderCommandEncoder) {
        var uniforms = BackdropUniforms(
            centerColor: Self.centerCharcoalColor,
            edgeColor: Self.edgeCharcoalColor
        )
        renderCommandEncoder.setRenderPipelineState(backdropPipelineState)
        renderCommandEncoder.setDepthStencilState(backdropDepthStencilState)
        renderCommandEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<BackdropUniforms>.stride, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }

    func renderGroundGrid(camera: RenderCamera, renderCommandEncoder: any MTLRenderCommandEncoder) {
        var uniforms = GridUniforms(
            viewProjectionMatrix: camera.projectionMatrix * camera.viewMatrix
        )
        renderCommandEncoder.setRenderPipelineState(gridPipelineState)
        renderCommandEncoder.setDepthStencilState(gridDepthStencilState)
        renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<GridUniforms>.stride, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}
