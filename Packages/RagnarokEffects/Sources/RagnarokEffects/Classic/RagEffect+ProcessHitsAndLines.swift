//
//  RagEffect+ProcessHitsAndLines.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

    // MARK: - EF_HIT1 (0)
    // CRagEffect::Hit1()

    // MARK: - EF_HIT2 (1)
    // CRagEffect::Hit2(int option)

    // MARK: - EF_HIT3 (2)
    // CRagEffect::Hit3()

    // MARK: - EF_HIT4 (3)
    // CRagEffect::Hit4()

    // MARK: - EF_HIT5 (4)
    // CRagEffect::Hit5()

    // MARK: - EF_HIT6 (5)
    // CRagEffect::Hit6()

    // MARK: - EF_THUNDERSTORM (30)
    // CRagEffect::Thunderstorm()

    // MARK: - EF_FIREFLY (45)
    // CRagEffect::FireSparks()

    // MARK: - EF_COLDHIT (51)
    // CRagEffect::ColdHit()

    // MARK: - EF_YUFITELHIT (94)
    // CRagEffect::YufitelHit(char kind)

    // MARK: - EF_SONICBLOWHIT (122)
    // CRagEffect::SonicBlowHit()

    // MARK: - EF_HITDARK (180)
    // CRagEffect::HitDark()

    // MARK: - EF_GUMGANG (203)
    // CRagEffect::SuperSlashFan(char count, char value)

    // MARK: - EF_TEIHIT2 (264)
    // CRagEffect::TEIHIT2()

    // MARK: - EF_CHEMICAL2 (303)
    // CRagEffect::SlashFan(std::int16_t reverse)

    // MARK: - EF_SPRINKLESAND (310)
    // CRagEffect::ThunderSparks()

    // MARK: - EF_HITLINE (330)

    /// Emits `PP_HITLINE` (70) bouncing white spark trails for `EF_HITLINE` (330).
    func whiteSparks(kind: Int16, context: EffectTickContext) {
        guard stateCnt >= 0, stateCnt <= 3 else {
            return
        }

        let texturePath = "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_hitline)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = -Int.random(in: 0..<26)
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<51) + 125)
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<8)) + 6.0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].alphaT = kind
        }
    }

    // MARK: - EF_SOULBREAKER (361)
    // CRagEffect::SonicWave(char sonic)

    // MARK: - EF_ENERGYDRAIN3 (383)
    // CRagEffect::SonicSlashFan(char kind)

    // MARK: - EF_SOULBREAKER2 (409)
    // CRagEffect::PurpleSlash(int angle)

    // MARK: - EF_DOUBLEGUMGANG (418)
    // CRagEffect::SuperSlashSpread(char count, char value)

    // MARK: - EF_HITLINE3 (428)

    /// Emits `PP_HITLINE3` (100) short spark streaks for `EF_HITLINE3` (428), `EF_HITLINE6` (431), and `EF_HITLINE7` (434).
    func whiteSparkStreak(kind: Int16, context: EffectTickContext) {
        let limit = if kind == 1 { 2 } else if kind == 3 { 5 } else { 0 }
        guard stateCnt >= 0, stateCnt < limit else {
            return
        }

        let texturePath = "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_hitline3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1

            if kind == 1 {
                primitive.state.slots[index].process = -Int.random(in: 0..<11)
                primitive.state.slots[index].maxHeight = 0.1
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<51) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<5)) + 5.0
                primitive.state.slots[index].vecTNow.y = 3.0
            } else if kind == 3 {
                primitive.state.slots[index].process = -30 - Int.random(in: 0..<41)
                primitive.state.slots[index].maxHeight = 0.07
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<121) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) + 6.0
                primitive.state.slots[index].vecTNow.y = 4.0
            } else {
                primitive.state.slots[index].process = -Int.random(in: 0..<26)
                primitive.state.slots[index].maxHeight = 0.1
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<(kind >= 3 ? 121 : 51)) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) + 6.0
                primitive.state.slots[index].vecTNow.y = 5.0
            }

            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<7)) * 0.1 + 0.6
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].alphaT = kind

            if kind == 1 {
                let tailCount = Int(primitive.state.slots[index].vecTNow.y)
                for _ in 0..<10 {
                    primitive.state.slots[index].height[0] = min(180.0, primitive.state.slots[index].height[0] + 6.0)
                    for layer in stride(from: tailCount, through: 1, by: -1) {
                        primitive.state.slots[index].height[layer] = primitive.state.slots[index].height[layer - 1]
                    }
                }
            }
        }
    }

    // MARK: - EF_ELECTRIC2 (433)

    /// Spawns `PP_ELECTRIC2` (102) directional lightning tubes for `EF_ELECTRIC2` (433).
    func electricArc(kind: Int16, angle: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_electric2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let heading = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].riseAngle = heading
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].height[0] = index < 2 ? Float(index * 180) : Float(index * 180 - 360)
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<6)) * 0.01 + 0.2
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
            }
            primitive.state.slots[index].alphaT = kind
        }
    }

    // MARK: - EF_CHEMICAL3 (439)
    // CRagEffect::LineStreakLayered(short kind)

    // MARK: - EF_YELLOWFLY1 (713)
    // CRagEffect::WhiteLightSparkle(char kind)

    // MARK: - EF_CIRCLEPOWER (757)
    // CRagEffect::EmpShockBurst(const char* name, char flag)

    // MARK: - EF_INFRAREDSCAN (794)

    /// Spawns primitive `135` sweeping electric jitter arcs for `EF_INFRAREDSCAN` (794).
    func electricFan(fade: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(135)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let facingDegrees = (targetObjectID ?? ownerObjectID)
            .flatMap { context.world.targetState(for: $0)?.facingAngle } ?? 0
        var initialAngle = Int16(Int(facingDegrees) - 90)
        if initialAngle < 0 {
            initialAngle += 360
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = index == 0 ? 250 : Int16(140 - index * 30)
            primitive.state.slots[index].riseAngle = initialAngle
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<11)) * 0.01
            primitive.state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 10.0, position.z)
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].alphaT = fade
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }

    // MARK: - EF_ENERVATION (813)
    // CRagEffect::TintedRisingSparkles(char)

    // MARK: - EF_CHOOKGI_N (833)
    // CRagEffect::ThunderFreeze(int)

    // MARK: - EF_CHEMICAL2DASH3 (836)
    // CRagEffect::LineStreakTextured(std::int16_t kind, const char* name)

    // MARK: - EF_DANCE1 (847)
    // CRagEffect::RisingSparkles(char colorMode)

    // MARK: - EF_CHEMICAL3S (893)
    // CRagEffect::LineStreakKind(std::int16_t kind)

    // MARK: - EF_NEW_TRIPLEATTACK (1409)
    // CRagEffect::LineStreak(std::int16_t kind)
}
