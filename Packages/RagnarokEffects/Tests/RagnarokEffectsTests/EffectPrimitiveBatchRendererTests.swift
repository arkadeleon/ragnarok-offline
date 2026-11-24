//
//  EffectPrimitiveBatchRendererTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import Metal
import RagnarokRendering
import RagnarokShaders
import simd
import Testing
@testable import RagnarokEffects

@Suite("EffectPrimitiveBatchRenderer")
struct EffectPrimitiveBatchRendererTests {
    private func approxEqual(_ a: Float, _ b: Float, tolerance: Float = 1e-4) -> Bool {
        abs(a - b) <= tolerance
    }

    private func approxEqual(_ a: SIMD3<Float>, _ b: SIMD3<Float>, tolerance: Float = 1e-4) -> Bool {
        approxEqual(a.x, b.x, tolerance: tolerance)
            && approxEqual(a.y, b.y, tolerance: tolerance)
            && approxEqual(a.z, b.z, tolerance: tolerance)
    }

    private func approxEqual(_ a: SIMD2<Float>, _ b: SIMD2<Float>, tolerance: Float = 1e-4) -> Bool {
        approxEqual(a.x, b.x, tolerance: tolerance)
            && approxEqual(a.y, b.y, tolerance: tolerance)
    }

    private func approxEqual(_ a: SIMD4<Float>, _ b: SIMD4<Float>, tolerance: Float = 1e-4) -> Bool {
        approxEqual(a.x, b.x, tolerance: tolerance)
            && approxEqual(a.y, b.y, tolerance: tolerance)
            && approxEqual(a.z, b.z, tolerance: tolerance)
            && approxEqual(a.w, b.w, tolerance: tolerance)
    }

    @Test("D3D blend factor mapping covers 1...15 and additive detection")
    func blendFactorMapping() {
        let expected: [(Int32, MTLBlendFactor)] = [
            (1, .zero),
            (2, .one),
            (3, .sourceColor),
            (4, .oneMinusSourceColor),
            (5, .sourceAlpha),
            (6, .oneMinusSourceAlpha),
            (7, .destinationAlpha),
            (8, .oneMinusDestinationAlpha),
            (9, .destinationColor),
            (10, .oneMinusDestinationColor),
            (11, .sourceAlphaSaturated),
            (12, .sourceAlpha),
            (13, .oneMinusSourceAlpha),
            (14, .blendColor),
            (15, .oneMinusBlendColor),
        ]

        for (d3d, mtl) in expected {
            let factor = EffectBlendFactor(d3dBlend: d3d)
            #expect(factor.mtlBlendFactor == mtl)
            #expect(factor.isAdditiveDestination == (d3d == 2))
        }

        // Unknown value falls back to sourceAlpha.
        let fallback = EffectBlendFactor(d3dBlend: 999)
        #expect(fallback == .sourceAlpha)
        #expect(fallback.mtlBlendFactor == .sourceAlpha)
    }

    @Test("Pipeline and depth-stencil cache keys hash and compare properly")
    func cacheKeysAndRenderState() {
        let k1 = EffectPrimitivePipelineKey(srcBlend: .sourceAlpha, dstBlend: .one)
        let k2 = EffectPrimitivePipelineKey(srcBlend: .sourceAlpha, dstBlend: .one)
        let k3 = EffectPrimitivePipelineKey(srcBlend: .one, dstBlend: .one)
        #expect(k1 == k2)
        #expect(k1 != k3)
        #expect(Set([k1, k2, k3]).count == 2)

        let d1 = EffectPrimitiveDepthStencilKey(depthTest: true, depthWrite: false)
        let d2 = EffectPrimitiveDepthStencilKey(depthTest: true, depthWrite: false)
        let d3 = EffectPrimitiveDepthStencilKey(depthTest: false, depthWrite: true)
        #expect(d1 == d2)
        #expect(d1 != d3)

        #expect(EffectPrimitiveRenderState.additive.isAdditive)
        #expect(EffectPrimitiveRenderState.pureAdditive.isAdditive)
        #expect(!EffectPrimitiveRenderState.alpha.isAdditive)
        #expect(!EffectPrimitiveRenderState.inverseMask.isAdditive)
    }

    @Test("ARGB unpacking produces normalized RGBA float4")
    func unpackARGB() {
        let color = EffectPrimitiveBatchCollector.unpackARGB(0x80FF4020)
        #expect(approxEqual(color, SIMD4<Float>(1.0, 64.0 / 255.0, 32.0 / 255.0, 128.0 / 255.0), tolerance: 1e-3))
    }

    @Test("EffectSpace quad and billboard conversion and batch merging/splitting")
    func collectorConversionAndBatching() {
        var collector = EffectPrimitiveBatchCollector(fog: Fog())
        let white = SIMD4<Float>(1, 1, 1, 1)

        // Append two quads with identical state -> should merge into 1 batch of 12 vertices.
        collector.appendEffectQuad(
            p0: SIMD3<Float>(0, 0, 0),
            p1: SIMD3<Float>(5, 0, 0),
            p2: SIMD3<Float>(5, -10, 0),
            p3: SIMD3<Float>(0, -10, 0),
            color0: white,
            color1: white,
            color2: white,
            color3: white,
            texture: nil,
            renderState: .additive,
            effectCenter: SIMD3<Float>(2.5, -5, 0)
        )
        collector.appendEffectQuad(
            p0: SIMD3<Float>(5, 0, 0),
            p1: SIMD3<Float>(10, 0, 0),
            p2: SIMD3<Float>(10, -10, 0),
            p3: SIMD3<Float>(5, -10, 0),
            color0: white,
            color1: white,
            color2: white,
            color3: white,
            texture: nil,
            renderState: .additive,
            effectCenter: SIMD3<Float>(7.5, -5, 0)
        )

        #expect(collector.batches.count == 1)
        #expect(collector.batches[0].mode == .world3D)
        #expect(collector.batches[0].vertices.count == 12)
        // Verify EffectSpace conversion: p2 = (5, -10, 0) -> world (1.0, 2.0, 0.0)
        #expect(approxEqual(collector.batches[0].vertices[2].position, SIMD3<Float>(1.0, 2.0, 0.0)))
        #expect(approxEqual(collector.batches[0].worldCenter, SIMD3<Float>(0.5, 1.0, 0.0)))

        // Append billboard quad -> different mode, should split into a second batch.
        collector.appendEffectBillboardQuad(
            anchorEffectPosition: SIMD3<Float>(10, -15, -5),
            sizeEffect: SIMD2<Float>(10, 10),
            rotationRadians: .pi * 0.5,
            color: white,
            texture: nil,
            renderState: .additive
        )

        #expect(collector.batches.count == 2)
        #expect(collector.batches[1].mode == .billboard3D)
        #expect(collector.batches[1].vertices.count == 6)
        #expect(approxEqual(collector.batches[1].vertices[0].position, SIMD3<Float>(2.0, 3.0, 1.0)))
        // Original TL (-1, +1) rotated +90 deg -> (-1, -1)
        #expect(approxEqual(collector.batches[1].vertices[0].billboardOffset, SIMD2<Float>(-1.0, -1.0)))

        // Append triangle with different renderState -> should split into a third batch.
        collector.appendEffectTriangle(
            p0: .zero,
            p1: SIMD3<Float>(5, 0, 0),
            p2: SIMD3<Float>(0, -5, 0),
            uv0: SIMD2<Float>(0, 0),
            uv1: SIMD2<Float>(1, 0),
            uv2: SIMD2<Float>(0, 1),
            color0: white,
            color1: white,
            color2: white,
            texture: nil,
            renderState: .alpha,
            effectCenter: .zero
        )

        #expect(collector.batches.count == 3)
        #expect(collector.batches[2].vertices.count == 3)
    }

    @Test("Renderer initializes fallback texture and caches pipeline/depth states on Metal device")
    func rendererPipelineAndDepthCache() throws {
        guard let device = MTLCreateSystemDefaultDevice(),
              RagnarokShadersLibrary(device) != nil else {
            return
        }

        let renderer = try EffectPrimitiveBatchRenderer(device: device, configuration: .default)
        #expect(renderer.fallbackWhiteTexture.width == 1)
        #expect(renderer.fallbackWhiteTexture.height == 1)
        #expect(renderer.cachedPipelineCount == 2)
        #expect(renderer.cachedDepthStencilCount == 1)

        // Requesting pre-warmed alpha pipeline should reuse cache.
        let alphaKey = EffectPrimitivePipelineKey(srcBlend: .sourceAlpha, dstBlend: .oneMinusSourceAlpha)
        #expect(renderer.renderPipelineState(for: alphaKey) != nil)
        #expect(renderer.cachedPipelineCount == 2)

        // Requesting inverseMask pipeline should lazily create and cache a 3rd pipeline.
        let maskKey = EffectPrimitivePipelineKey(srcBlend: .zero, dstBlend: .oneMinusSourceColor)
        #expect(renderer.renderPipelineState(for: maskKey) != nil)
        #expect(renderer.cachedPipelineCount == 3)

        // Requesting non-default depth state should lazily create and cache a 2nd depth state.
        let noDepthKey = EffectPrimitiveDepthStencilKey(depthTest: false, depthWrite: false)
        #expect(renderer.depthStencilState(for: noDepthKey) != nil)
        #expect(renderer.cachedDepthStencilCount == 2)
    }
}
