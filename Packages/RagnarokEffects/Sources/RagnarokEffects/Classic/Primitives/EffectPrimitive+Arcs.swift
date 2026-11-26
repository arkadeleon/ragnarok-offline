//
//  EffectPrimitive+Arcs.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import Foundation
import simd

extension EffectPrimitive {

    // MARK: - PP_WIND (62)

    /// Motion update for `PP_WIND` (62) orbiting wind ribbon arcs at 60Hz.
    func primWind() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].rotStart += 5
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            let mode = state.slots[index].alphaT
            let maxArc: Int16 = mode == 2 ? 180 : 120
            state.slots[index].fullDisplayAngle = min(maxArc, state.slots[index].fullDisplayAngle + 3)

            if mode == 1 {
                if process > 20 {
                    state.slots[index].alphaB = max(0, state.slots[index].alphaB - 2)
                    state.slots[index].distance += 0.1
                }
            } else if mode == 2 {
                if process > 50 {
                    state.slots[index].alphaB = max(0, state.slots[index].alphaB - 1)
                }
                if process > 12 {
                    state.slots[index].distance += 0.1
                }
            }

            if process > 1400 {
                if mode != 3 {
                    state.slots[index].alphaB -= 3
                }
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                }
            }

            if mode == 2 {
                if process < 12 {
                    state.slots[index].alphaB += 1
                }
            } else if process < 12 {
                state.slots[index].alphaB = min(250, state.slots[index].alphaB + 10)
            }
        }
    }

    /// Geometry submission for `PP_WIND` (62) elevated rising ribbon arcs.
    func renderRiseArc(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for ec in 0..<4 where state.slots[ec].life == 1 {
            let fullDisplayAngle = Int(state.slots[ec].fullDisplayAngle)
            let step = fullDisplayAngle / 21
            guard step > 0 else {
                continue
            }

            let riseCos = EffectSpace.cosine(degrees: Int(state.slots[ec].riseAngle))
            let riseSin = EffectSpace.sine(degrees: Int(state.slots[ec].riseAngle))
            let maxHeight = state.slots[ec].maxHeight
            let dist = state.slots[ec].distance

            var i = 0
            var offset = 0
            while offset < fullDisplayAngle {
                var angle = (Int(state.slots[ec].rotStart) + offset) % 360
                if angle < 0 {
                    angle += 360
                }
                if fullDisplayAngle == 360 && i == 20 {
                    angle = Int(state.slots[ec].rotStart)
                }

                let cosine = EffectSpace.cosine(degrees: angle)
                let sine = EffectSpace.sine(degrees: angle)
                let curB = SIMD3<Float>(cosine * dist, -maxHeight, sine * dist)
                state.slots[ec].vecBNow = curB

                let height = state.slots[ec].height[i]
                let riseX = riseCos * height
                let riseY = riseSin * height
                let curT = SIMD3<Float>(curB.x + cosine * riseX, -(riseY + maxHeight), curB.z + sine * riseX)
                state.slots[ec].vecTNow = curT

                if i > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: i - 1,
                        alphaB: state.slots[ec].alphaB,
                        alphaT: state.slots[ec].alphaB,
                        v1: state.slots[ec].vecBPre,
                        v2: curB,
                        v3: curT,
                        v4: state.slots[ec].vecTPre,
                        textureIndex: 0
                    )
                }

                i = min(20, i + 1)
                state.slots[ec].vecBPre = curB
                state.slots[ec].vecTPre = curT
                offset += step
            }
        }
    }

    // MARK: - Primitive 137

    /// Motion update for primitive `137` rising arc walls at 60Hz.
    func primHeightRamp() {
        for index in 0..<4 where state.slots[index].life == 1 {
            let process = state.slots[index].process + 1
            state.slots[index].process = process

            var rotStart = state.slots[index].rotStart + 1
            if rotStart >= 360 {
                rotStart -= 360
            }
            state.slots[index].rotStart = rotStart

            if process >= 125 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 15)
                state.slots[index].maxHeight = max(0, state.slots[index].maxHeight - 5.0)
            }

            let maxHeight = state.slots[index].maxHeight
            for i in 0..<21 {
                let value: Float
                if process < 100 {
                    value = 0
                } else if process <= 115 {
                    value = EffectSpace.sine(degrees: 6 * process - 600) * maxHeight
                } else {
                    value = maxHeight
                }
                state.slots[index].height[i] = max(0, value)
            }
        }
    }

    /// Geometry submission for primitive `137`, emitting inner red arc walls and outer palette arc walls.
    func renderArcWalls(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            let fullAngle = Int(slot.fullDisplayAngle)
            let step = fullAngle / 4
            guard step > 0 else {
                continue
            }

            let offsetPos = slot.vecBNow + slot.vecTPre
            let riseCos = EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let riseSin = EffectSpace.sine(degrees: Int(slot.riseAngle))

            var prevB = SIMD3<Float>.zero
            var prevT = SIMD3<Float>.zero
            var segmentIndex = 0
            var angleOffset = 0
            while angleOffset <= fullAngle {
                var angle = (Int(slot.rotStart) + angleOffset) % 360
                if angle < 0 {
                    angle += 360
                }
                if fullAngle == 360 && segmentIndex == 4 {
                    angle = Int(slot.rotStart)
                }

                let cs = EffectSpace.cosine(degrees: angle)
                let sn = EffectSpace.sine(degrees: angle)
                let baseX = slot.distance * cs
                let baseZ = slot.distance * sn
                let rise = slot.height[segmentIndex]
                let riseX = rise * riseCos

                let curB = SIMD3<Float>(baseX, 0, baseZ) + offsetPos
                let curT = SIMD3<Float>(riseX * cs + baseX, -(rise * riseSin), riseX * sn + baseZ) + offsetPos

                if segmentIndex > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB / 5,
                        v1: prevB,
                        v2: curB,
                        v3: prevT,
                        v4: curT,
                        blendSelector: 1,
                        textureIndex: 0,
                        isWorldPosition: false,
                        red: 255,
                        green: 10,
                        blue: 10
                    )
                }

                segmentIndex = min(4, segmentIndex + 1)
                prevB = curB
                prevT = curT
                angleOffset += step
            }

            prevB = .zero
            prevT = .zero
            segmentIndex = 0
            angleOffset = 0
            while angleOffset <= fullAngle {
                var angle = (Int(slot.rotStart) + 45 + angleOffset) % 360
                if angle < 0 {
                    angle += 360
                }
                if fullAngle == 360 && segmentIndex == 4 {
                    angle = Int(slot.rotStart)
                }

                let cs = EffectSpace.cosine(degrees: angle)
                let sn = EffectSpace.sine(degrees: angle)
                let baseX = slot.distance * cs * 1.5
                let baseZ = slot.distance * sn * 1.5
                let rise = slot.height[segmentIndex]
                let riseX = rise * riseCos

                let curB = SIMD3<Float>(baseX, 0, baseZ) + offsetPos
                let curT = SIMD3<Float>(riseX * cs + baseX, -(rise * riseSin), riseX * sn + baseZ) + offsetPos

                if segmentIndex > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: segmentIndex - 1,
                        alphaB: slot.alphaB,
                        alphaT: slot.alphaB,
                        v1: prevB,
                        v2: curB,
                        v3: curT,
                        v4: prevT,
                        textureIndex: 0
                    )
                }

                segmentIndex = min(4, segmentIndex + 1)
                prevB = curB
                prevT = curT
                angleOffset += step
            }
        }
    }

    // MARK: - Primitive 144

    /// Motion update for primitive `144` expanding ground arc rings at 60Hz.
    func primGI1() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].distance += 0.07
            state.slots[index].riseAngle -= 1
            if state.slots[index].riseAngle < 10 {
                state.slots[index].riseAngle = 10
                state.slots[index].alphaB = 0
            }

            if state.slots[index].distance >= 4.0 {
                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB <= 0 {
                    state.slots[index].alphaB = 0
                    if state.slots[index].process < state.duration - 30 {
                        state.slots[index].distance = 4.0 - 0.63
                        state.slots[index].riseAngle = 65 + 9
                    }
                }
            } else {
                state.slots[index].alphaB += 10
            }

            updateWaveHeights(forSlot: index, amplitude: 0.3)
        }
    }

    /// Geometry submission for primitive `144`, rendering 20-segment stepped ground arcs.
    func renderGroundArcStep(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let textureCount = max(1, state.totalTexture)

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            let baseY: Float
            if slot.maxHeight == 6.001 {
                baseY = -2.0
            } else if slot.maxHeight == 24.001 {
                baseY = -1.0
            } else {
                baseY = 0.0
            }

            let textureIndex = slot.process % textureCount
            emitArcRing20(
                slot: slot,
                radius: slot.distance,
                baseY: baseY,
                baseOffset: .zero,
                topOffset: .zero
            ) { segmentIndex, prevB, curB, curT, prevT in
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    texPart: segmentIndex - 1,
                    alphaB: slot.alphaB,
                    alphaT: slot.alphaB,
                    v1: prevB,
                    v2: curB,
                    v3: curT,
                    v4: prevT,
                    textureIndex: textureIndex
                )
            }
        }
    }

    // MARK: - Primitive 146

    /// Motion update for primitive `146` drifting trailing arc rings at 60Hz.
    func primDriftingRings(context: EffectTickContext) {
        followMaster()

        let profile: [Float] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
        let alphaLimit: Int16 = context.usesMinimalEffects ? 125 : 250

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let angle = state.slots[index].rotStart
            var heading = Int(angle) + 345
            if heading >= 360 {
                heading -= 360
            }
            state.slots[index].vecTNow.x += EffectSpace.cosine(degrees: heading)
            state.slots[index].vecTNow.z += EffectSpace.sine(degrees: heading)
            if angle >= 360 {
                state.slots[index].rotStart = angle - 360
            }

            if process < 10 {
                state.slots[index].alphaB = min(alphaLimit, state.slots[index].alphaB + 25)
            } else {
                state.slots[index].alphaB -= 10
                if state.slots[index].alphaB < 0 {
                    state.slots[index].riseAngle -= 20
                    state.slots[index].alphaB = 0
                    state.slots[index].process = 0
                    state.slots[index].distance -= 0.4
                    if state.slots[index].riseAngle <= 40 {
                        state.slots[index].life = 0
                        state.slots[index].riseAngle = 40
                    }
                }
            }

            let currentProcess = state.slots[index].process
            let maxHeight = state.slots[index].maxHeight
            for point in 0..<21 {
                var scale: Float = 1.0
                for step in 0..<6 where point == step || point == 20 - step {
                    scale = profile[step]
                }

                var value = scale * maxHeight
                if currentProcess <= 15 {
                    value *= EffectSpace.sine(degrees: 6 * currentProcess)
                }
                state.slots[index].height[point] = max(0, value)
            }
        }
    }

    /// Geometry submission for primitive `146`, rendering 20-segment trailing arcs offset by `slots[0].vecTNow`.
    func renderTrailingArc(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let textureCount = max(1, state.totalTexture)
        let drift = state.slots[0].vecTNow
        let baseOffset = SIMD3<Float>(-drift.x * 0.75, 0, -drift.z * 0.75)
        let topOffset = SIMD3<Float>(-drift.x, 0, -drift.z)

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.process > 0 else {
                continue
            }

            let textureIndex = slot.process % textureCount
            emitArcRing20(
                slot: slot,
                radius: slot.distance,
                baseY: 0,
                baseOffset: baseOffset,
                topOffset: topOffset
            ) { segmentIndex, prevB, curB, curT, prevT in
                state.size = slot.vecTPre.x
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    texPart: segmentIndex - 1,
                    alphaB: slot.alphaB,
                    alphaT: slot.alphaB,
                    v1: prevB,
                    v2: curB,
                    v3: curT,
                    v4: prevT,
                    textureIndex: textureIndex
                )
            }
        }
    }

    // MARK: - Primitive 149

    /// Motion update for primitive `149` rotating wave-height ground arcs at 60Hz.
    func primWaveHeights() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].rotStart += 3
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process < 30 {
                state.slots[index].alphaB = min(100, state.slots[index].alphaB + 3)
            }
            if process > state.duration - 46 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 2)
            }

            updateWaveHeights(forSlot: index, amplitude: 0.3)
        }
    }

    /// Geometry submission for primitive `149`, rendering dual-pass glowing 20-segment ground arcs.
    func renderGroundArcGlow(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        usesMinimalEffects: Bool = false
    ) {
        let textureCount = max(1, state.totalTexture)

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            let radius = EffectSpace.sine(degrees: Int(slot.rotStart)) + slot.distance
            let textureIndex: Int
            if slot.alphaT == 10 {
                textureIndex = (slot.process / 3) % textureCount
            } else {
                textureIndex = slot.process % textureCount
            }

            emitArcRing20(
                slot: slot,
                radius: radius,
                baseY: 0,
                baseOffset: .zero,
                topOffset: .zero
            ) { segmentIndex, prevB, curB, curT, prevT in
                if slot.alphaT != 10 {
                    state.size = 0
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: segmentIndex - 1,
                        alphaB: slot.alphaB,
                        alphaT: slot.alphaB,
                        v1: prevB,
                        v2: curB,
                        v3: curT,
                        v4: prevT,
                        textureIndex: textureIndex
                    )
                }

                var glowAlpha = slot.alphaB
                switch slot.alphaT {
                case ...2:
                    state.size = 17.0
                    glowAlpha = slot.alphaB &* 3
                case 3:
                    state.size = 18.0
                    glowAlpha = slot.alphaB &* 3
                case 4:
                    state.size = 19.0
                    glowAlpha = slot.alphaB &* 2
                case 5:
                    state.size = 20.0
                    glowAlpha = slot.alphaB &* 2
                case 6:
                    state.size = 5.0
                    glowAlpha = slot.alphaB &* 2
                case 7:
                    state.size = 21.0
                    glowAlpha = slot.alphaB &* 2
                case 8:
                    state.size = 22.0
                    glowAlpha = slot.alphaB &* 2
                case 9:
                    state.size = 30.0
                    glowAlpha = usesMinimalEffects ? slot.alphaB : slot.alphaB &* 2
                case 10:
                    state.size = 6.0
                    glowAlpha = slot.alphaB &* 3
                case 11:
                    state.size = 32.0
                    glowAlpha = usesMinimalEffects ? slot.alphaB : slot.alphaB &* 2
                default:
                    break
                }

                if glowAlpha > 255 {
                    glowAlpha = 255
                }

                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    texPart: segmentIndex - 1,
                    alphaB: glowAlpha,
                    alphaT: slot.alphaB,
                    v1: prevB,
                    v2: curB,
                    v3: curT,
                    v4: prevT,
                    textureIndex: textureIndex
                )
            }
        }
    }

    // MARK: - Primitive 158

    /// Motion update for primitive `158` expanding ground arc rings at 60Hz.
    func primGI4() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].distance += 0.07
            state.slots[index].riseAngle -= 1
            if state.slots[index].riseAngle < 10 {
                state.slots[index].riseAngle = 10
                state.slots[index].alphaB = 0
            }

            if state.slots[index].distance >= 3.5 {
                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB <= 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].distance = 3.5 - 0.63
                    state.slots[index].riseAngle = 65 + 9
                }
            } else {
                state.slots[index].alphaB += 10
            }

            updateWaveHeights(forSlot: index, amplitude: 0.15)
        }
    }

    /// Geometry submission for primitive `158`, rendering elevated 20-segment ground arcs.
    func renderGroundArc(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let textureCount = max(1, state.totalTexture)

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.process > 0 else {
                continue
            }

            let textureIndex = slot.process % textureCount
            emitArcRing20(
                slot: slot,
                radius: slot.distance,
                baseY: 5.0,
                baseOffset: .zero,
                topOffset: .zero
            ) { segmentIndex, prevB, curB, curT, prevT in
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    texPart: segmentIndex - 1,
                    alphaB: slot.alphaB,
                    alphaT: slot.alphaB,
                    v1: prevB,
                    v2: curB,
                    v3: curT,
                    v4: prevT,
                    textureIndex: textureIndex
                )
            }
        }
    }

    // MARK: - Primitive 160

    /// Motion update for primitive `160` camera-facing glow follow frames at 60Hz.
    func primGlowFollow(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        if state.slots[0].process < 30 {
            if state.slots[0].flag1[4] == 31 {
                state.slots[0].alphaB += 8
            } else {
                state.slots[0].alphaB = min(60, state.slots[0].alphaB + 3)
            }
        }

        state.slots[0].alphaB = max(0, min(255, state.slots[0].alphaB))

        state.slots[0].height[8] += 1.0
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }

        state.slots[0].vecBNow = SIMD3<Float>(position.x, state.slots[0].vecBPre.y, position.z)
    }

    /// Geometry submission for primitive `160`, rendering dual-layer billboarded polygon frames.
    func renderPolygonFrames(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let textureIndex = Int(UInt8(bitPattern: slot.flag1[0]))
            let pulsingRadius = slot.distance * EffectSpace.sine(degrees: Int(slot.height[8])) * 0.05 + slot.distance

            let passes: [(radius: Float, isPulsing: Bool)] = [
                (slot.distance, false),
                (pulsingRadius, true),
            ]

            for pass in passes {
                var (p0, p1, p2, p3) = Self.polygonCorners(
                    radius: pass.radius,
                    startAngle: Int(slot.fullDisplayAngle),
                    shape: slot.height[10]
                )

                let topZ = max(max(p0.z, p1.z), max(p2.z, p3.z))
                p0.z -= topZ
                p1.z -= topZ
                p2.z -= topZ
                p3.z -= topZ

                Self.towardScreen(&p0, &p1, &p2, &p3, rot0: rot0, rot1: rot1)

                p0 += slot.vecBNow
                p1 += slot.vecBNow
                p2 += slot.vecBNow
                p3 += slot.vecBNow

                switch slot.flag1[2] {
                case 0, 3:
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: p0,
                        v2: p1,
                        v3: p2,
                        v4: p3,
                        blendSelector: 1,
                        textureIndex: textureIndex,
                        isWorldPosition: true,
                        red: 255,
                        green: 255,
                        blue: 255
                    )
                case 19:
                    let greenTint: UInt8 = pass.isPulsing ? 105 : 205
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: p1,
                        v2: p0,
                        v3: p3,
                        v4: p2,
                        blendSelector: 0,
                        textureIndex: textureIndex,
                        isWorldPosition: true,
                        red: greenTint,
                        green: 255,
                        blue: greenTint
                    )
                case 20:
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: p1,
                        v2: p0,
                        v3: p3,
                        v4: p2,
                        blendSelector: 0,
                        textureIndex: textureIndex,
                        isWorldPosition: true,
                        red: 255,
                        green: 5,
                        blue: 5
                    )
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: p1,
                        v2: p0,
                        v3: p3,
                        v4: p2,
                        blendSelector: 0,
                        textureIndex: textureIndex,
                        isWorldPosition: true,
                        red: 255,
                        green: 155,
                        blue: 155
                    )
                case 21 where !pass.isPulsing:
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: p1,
                        v2: p0,
                        v3: p3,
                        v4: p2,
                        blendSelector: 1,
                        textureIndex: textureIndex,
                        isWorldPosition: true,
                        red: 225,
                        green: 255,
                        blue: 225
                    )
                default:
                    break
                }
            }
        }
    }

    // MARK: - Primitive 173

    /// Motion update for primitive `173` slow-rotating wave-height ground arcs at 60Hz.
    func primWaveHeightsSlow(context: EffectTickContext) {
        followMaster()

        let alphaLimit: Int16 = context.usesMinimalEffects ? 80 : 150

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].rotStart += 1
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process < 30 {
                state.slots[index].alphaB = min(alphaLimit, state.slots[index].alphaB + 5)
            }
            if process > state.duration - 46 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 4)
            }

            updateWaveHeights(forSlot: index, amplitude: 0.3)
        }
    }

    /// Geometry submission for primitive `173`, sharing the elevated 20-segment ground arc layout.
    func renderGroundArc2(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        renderGroundArc(into: &collector, assets: assets)
    }

    // MARK: - Shared Arc Helpers

    private func updateWaveHeights(forSlot index: Int, amplitude: Float) {
        let middle = 10
        let step = 9
        let process = state.slots[index].process
        let maxHeight = state.slots[index].maxHeight
        let phase = if index < 2 {
            (process + index * 90) % 360
        } else {
            (process * 2 + index * 90) % 360
        }
        let waveSin = EffectSpace.sine(degrees: phase)

        for value in 0..<21 {
            let sinLimit = 90 + (value - middle) * step
            state.slots[index].height[value] = maxHeight + maxHeight * EffectSpace.sine(degrees: sinLimit) * amplitude * waveSin
        }
    }

    private func emitArcRing20(
        slot: EffectPrimitiveSlot,
        radius: Float,
        baseY: Float,
        baseOffset: SIMD3<Float>,
        topOffset: SIMD3<Float>,
        emitSegment: (Int, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>) -> Void
    ) {
        let fullAngle = Int(slot.fullDisplayAngle)
        let step = fullAngle / 20
        guard step > 0 else {
            return
        }

        let riseCos = EffectSpace.cosine(degrees: Int(slot.riseAngle))
        let riseSin = EffectSpace.sine(degrees: Int(slot.riseAngle))

        var prevB = SIMD3<Float>.zero
        var prevT = SIMD3<Float>.zero
        var segmentIndex = 0
        var offset = 0
        while offset <= fullAngle {
            var angle = (Int(slot.rotStart) + offset) % 360
            if angle < 0 {
                angle += 360
            }
            if fullAngle == 360 && segmentIndex == 20 {
                angle = Int(slot.rotStart)
            }

            let cs = EffectSpace.cosine(degrees: angle)
            let sn = EffectSpace.sine(degrees: angle)
            let baseX = radius * cs
            let baseZ = radius * sn
            let rise = slot.height[segmentIndex]
            let riseX = rise * riseCos

            let curB = SIMD3<Float>(baseX, baseY, baseZ) + baseOffset
            let curT = SIMD3<Float>(riseX * cs + baseX, baseY - rise * riseSin, riseX * sn + baseZ) + topOffset

            if segmentIndex > 0 {
                emitSegment(segmentIndex, prevB, curB, curT, prevT)
            }

            segmentIndex = min(20, segmentIndex + 1)
            prevB = curB
            prevT = curT
            offset += step
        }
    }

    static func polygonCorners(
        radius: Float,
        startAngle: Int,
        shape: Float
    ) -> (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>) {
        func wrapped(_ value: Int) -> Int {
            ((value % 360) + 360) % 360
        }

        let step1: Int
        let step2: Int
        let step3: Int
        if shape == 0.0 {
            (step1, step2, step3) = (90, 90, 90)
        } else if shape == 1.0 {
            (step1, step2, step3) = (60, 120, 60)
        } else if shape == 2.0 {
            (step1, step2, step3) = (130, 50, 130)
        } else {
            (step1, step2, step3) = (0, 0, 0)
        }

        let a0 = wrapped(startAngle)
        let a1 = wrapped(a0 - step1)
        let a2 = wrapped(a1 - step2)
        let a3 = wrapped(a2 - step3)

        let p0 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a0), 0, radius * EffectSpace.sine(degrees: a0))
        let p1 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a1), 0, radius * EffectSpace.sine(degrees: a1))
        let p2 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a2), 0, radius * EffectSpace.sine(degrees: a2))
        let p3 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a3), 0, radius * EffectSpace.sine(degrees: a3))
        return (p0, p1, p2, p3)
    }
}
