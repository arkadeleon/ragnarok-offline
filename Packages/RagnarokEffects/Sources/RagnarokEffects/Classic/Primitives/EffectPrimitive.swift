//
//  EffectPrimitive.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import Metal
import RagnarokRendering
import simd

/// Base primitive runtime owned by a `RagEffect` host, executing 60Hz state updates
/// and emitting batched vertices through `EffectPrimitiveBatchCollector`.
@MainActor
public final class EffectPrimitive {
    public typealias TickHandler = (EffectPrimitive, EffectTickContext) -> Bool
    public typealias RenderHandler = (EffectPrimitive, inout EffectPrimitiveBatchCollector, any EffectWorldContext, EffectAssetStore?) -> Void

    public weak var master: RagEffect?
    public var id: EffectPrimitiveID
    public var state: EffectPrimitiveState

    public var position: SIMD3<Float> = .zero
    public var angle: Float = 0
    public var previousAnimation: Int = 0
    public var currentMotion: Int = 0
    public var spriteFrameCount: Int = 1

    public private(set) var isAlive: Bool = true

    var customTick: TickHandler?
    var customRender: RenderHandler?
    private var lastUsesMinimalEffects: Bool = false

    public init(id: EffectPrimitiveID = .pp_2dtexture) {
        self.id = id
        self.state = EffectPrimitiveState()
        self.state.count = id.rawValue
    }

    public func initialize(master: RagEffect, id: EffectPrimitiveID, deltaPos: SIMD3<Float>) {
        self.master = master
        self.id = id
        self.state.count = id.rawValue
        self.state.deltaPos += deltaPos
        self.state.orgPos = master.position
        self.position = self.state.orgPos
        self.state.isChangeProcessed = 0
    }

    /// Detaches from the owning `RagEffect` when the host retires or requests separation.
    public func detachMaster() {
        master = nil
    }

    public func stop() {
        detachMaster()
        isAlive = false
    }

    // MARK: - 60Hz Tick & Render Dispatch

    public func tick(context: EffectTickContext) {
        guard isAlive, master != nil else {
            isAlive = false
            return
        }

        lastUsesMinimalEffects = context.usesMinimalEffects

        if let customTick {
            if !customTick(self, context) {
                isAlive = false
                return
            }
        } else {
            switch id {
            case .pp_2dtexture:
                if !move2DPrimitive() {
                    isAlive = false
                    return
                }
            case .pp_2dtextureorbit:
                if !prim2DTextureOrbit() {
                    isAlive = false
                    return
                }
            case .pp_2dquad:
                if !move2DPrimitive() {
                    isAlive = false
                    return
                }
            case .pp_2dflash:
                prim2DFlash()
            case .pp_2dcircle:
                prim2DCircle()
            case .pp_3dparticle:
                if !prim3DParticle(context: context) {
                    isAlive = false
                    return
                }
            case .pp_3dparticlegravity:
                if !prim3DParticleGravity(context: context) {
                    isAlive = false
                    return
                }
            case .pp_3dparticleorbit:
                if !prim3DParticleOrbit(context: context) {
                    isAlive = false
                    return
                }
            case .pp_3dparticlespline:
                if !prim3DParticleSpline(context: context) {
                    isAlive = false
                    return
                }
            case .pp_3dquadhorn:
                advanceEffectPrimitive()
            case .pp_3dspline, .pp_3dspiral:
                prim3DSpiral()
            case .pp_3dcircle:
                prim3DCircle()
            case .pp_3dcylinder:
                if !prim3DCylinder() {
                    isAlive = false
                    return
                }
            case .pp_3dsphere:
                prim3DSphere()
            case .pp_3dtexture, .pp_3dcrosstexture:
                if !moveEffectPrimitive(context: context) {
                    isAlive = false
                    return
                }
            case .pp_3dcylinderhalf:
                if !prim3DCylinderHalf() {
                    isAlive = false
                    return
                }
            case .pp_3dparticle_nomaster:
                if !prim3DParticleNoMaster(context: context) {
                    isAlive = false
                    return
                }
            case .pp_3dtexture_nomaster:
                if !prim3DTextureNoMaster(context: context) {
                    isAlive = false
                    return
                }
            case .pp_3dflash:
                prim3DFlash()
            case .pp_3dline:
                prim3DLine()
            case .pp_3dcasting:
                prim3DCasting()
            case .pp_3dcasting_2:
                prim3DCasting2()
            case .pp_3dcasting_3:
                prim3DCasting3()
            case 26:
                primFloorSpin26()
            case .pp_mapparticle:
                primMapParticle(context: context)
            case 28:
                primFloorPulse28()
            case 29:
                primFloatingMotes(context: context)
            case 30:
                primCasting30()
            case 31:
                primWaveSpin()
            case 32:
                primDriftingOrbs(context: context)
            case 33:
                primFieldFireflies(context: context)
            case .pp_gi_3:
                primGI3()
            case 35:
                primFloatingBubbles(context: context)
            case 36:
                primCasting36()
            case .pp_grandcross2:
                primGrandCross2()
            case .pp_linelink:
                primLineLink(context: context)
            case 39:
                primFloorSpin39()
            case .pp_sakura:
                if !primSakura(context: context) {
                    isAlive = false
                    return
                }
            case 41:
                primCasting41()
            case .pp_shieldboomerang:
                primShieldBoomerang(context: context)
            case .pp_intimidate:
                primIntimidate(context: context)
            case 44:
                primExpandPulse(context: context)
            case .pp_teihit2:
                primTeiHit2(context: context)
            case 46:
                primSpriteSlotFollow(context: context)
            case .pp_bottom:
                primBottom(context: context)
            case .pp_bottom2:
                primBottom2()
            case .pp_bottomout:
                primBottomOut(context: context)
            case 50:
                primCasting50()
            case 51:
                primSpriteSlotProcess(context: context)
            case .pp_pokjuk:
                primPokJuk(context: context)
            case .pp_throwitem:
                primThrowItem(context: context)
            case .pp_chemicalprotection:
                primChemical(context: context)
            case .pp_chemical2:
                primChemical2(context: context)
            case .pp_chemical3:
                primChemical3(context: context)
            case 57:
                primCasting57()
            case .pp_firstaid:
                primFirstAid(context: context)
            case .pp_particle_up:
                primParticleUp(context: context)
            case 60:
                primPulsingColumns(context: context)
            case .pp_guard:
                primGuard(context: context)
            case .pp_wind:
                primWind()
            case 63:
                primRippleRings()
            case .pp_rect_up:
                primPulseRing()
            case .pp_3dcasting_4:
                prim3DCasting4()
            case .pp_forest:
                primForest()
            case 67:
                primFadeSquare67()
            case .pp_asuracasting:
                primAsuraCasting(context: context)
            case 69:
                primPentaRing()
            case .pp_hitline:
                primHitLine()
            case .pp_blind:
                primFadeInFollow(context: context)
            case 72:
                primPoison(context: context)
            case .pp_magnum2:
                primMagnum2()
            case 74:
                primHalfSphere2()
            case .pp_slash1:
                primSlash1()
            case .pp_saintwing:
                primSaintWing(context: context)
            case .pp_spherewind:
                primSphereWind()
            case .pp_colorpaper:
                primColorPaper()
            case 79:
                primScrollColumn()
            case 80:
                primFallingPetals(context: context)
            case 81:
                primBeam()
            case 82:
                primAuraGlow(context: context)
            case .pp_ghost:
                if !primGhost(context: context) {
                    isAlive = false
                    return
                }
            case .pp_superangel:
                if !primSuperAngel(context: context) {
                    isAlive = false
                    return
                }
            case 86:
                primFloorSquare86()
            case 87:
                primBubbleSwirl(context: context)
            case 88:
                primGrowFollow()
            case 89:
                primFanBeam()
            case .pp_rect_up2:
                primFadingColumns()
            case .pp_spherewind2:
                primSphereWind2()
            case 92:
                primFloorSquare92()
            case .pp_rainbow:
                primRainbow()
            case .pp_peong:
                primPeong(context: context)
            case .pp_effecttexture2:
                primEffectTexture2(context: context)
            case .pp_peongup:
                primPeongUp(context: context)
            case .pp_tanji2:
                primTanji2(context: context)
            case 98:
                primRing98()
            case .pp_doublegumgang:
                primFloatingBubbles(context: context)
            case .pp_hitline3:
                primHitLine3()
            case .pp_electric:
                primElectric()
            case .pp_electric2:
                primElectric2()
            case 103:
                primSpinFade()
            case .pp_halfsphere:
                primHalfSphere(context: context)
            case 105:
                primCone(context: context)
            case .pp_attackenergy2:
                primAttackEnergy2(context: context)
            case .pp_3dcasting_5:
                prim3DCasting5()
            case .pp_flowercast:
                primFlowerCast()
            case .pp_soullink:
                primSoulLink(context: context)
            case .pp_heal_low:
                primPulsingColumns(context: context)
            case .pp_soulparticle:
                primSoulParticle(context: context)
            case 112:
                primMagicTarget()
            case 113:
                primCasting113()
            case .pp_hermode:
                primHermode()
            case 115:
                primParticleSpread(context: context)
            case .pp_shieldboomerang3:
                primShieldBoomerang3(context: context)
            case .pp_3dquadhorn2:
                prim3DQuadHorn2()
            case .pp_aciddemon:
                primAcidDemon()
            case 119:
                primFloorSquare119()
            case .pp_sma:
                primSMA(context: context)
            case .pp_sma2:
                primSMA2()
            case 122:
                primSTIN3(context: context)
            case .pp_twilight:
                primTwilight(context: context)
            case .pp_kouenka:
                if !primKouenka(context: context) {
                    isAlive = false
                    return
                }
            case .pp_stin4:
                primSTIN4(context: context)
            case 126:
                primRotatedRing()
            case .pp_bubble_drop:
                primBubbleDrop(context: context)
            case .pp_effecttexture_ani:
                primEffectTextureAni(context: context)
            case 129:
                primBobbing()
            case 130:
                primDriftingSquares(context: context)
            case 131:
                primRisingFan2(context: context)
            case 132:
                primColorPanel()
            case 133:
                primAnimatedFlash(context: context)
            case 134:
                primBladeTrail(context: context)
            case 135:
                primTrailShift()
            case 136:
                primRandomSpin(context: context)
            case 137:
                primHeightRamp()
            case 138:
                primChookgi(context: context)
            case 139:
                primBreathingWave()
            case 140:
                primFrameFade(context: context)
            case 141:
                primRiseFollow(context: context)
            case 142:
                primWaterFall()
            case 143:
                primTextureSpin()
            case 144:
                primGI1()
            case 145:
                primDriftingSparks(context: context)
            case 146:
                primDriftingRings(context: context)
            case 147:
                primRisingFan(context: context)
            case 148:
                followMasterAndTickSlots()
            case 149:
                primWaveHeights()
            case 150:
                primFallingPetals2(context: context)
            case 151:
                primSpiralFade(context: context)
            case 152:
                if !primWanderingSlots(context: context) {
                    isAlive = false
                    return
                }
            case 153:
                if !primFadeAlpha(context: context) {
                    isAlive = false
                    return
                }
            case 154:
                primFlashFade(context: context)
            case 155:
                primWanderingFlames(context: context)
            case 156:
                primHoverFollow(context: context)
            case 157:
                primOrbitFade(context: context)
            case 158:
                primGI4()
            case 159:
                primSpiralCollapse()
            case 160:
                primGlowFollow(context: context)
            case 161:
                primTwinSpin()
            case 162:
                followMasterAndTickSlots()
            case 163:
                primTextureFrames()
            case 164:
                primFrameScroll()
            case 165:
                primScrollTexture()
            case 166:
                primFramePhase()
            case 167:
                if !prim3DSlotParticle(context: context) {
                    isAlive = false
                    return
                }
            case 168:
                syncSpriteFrameCount(assets: context.assets)
                if !followMasterAndAdvance() {
                    isAlive = false
                    return
                }
            case 169:
                primCasting169()
            case 170:
                primWanderingFlames2(context: context)
            case 171:
                primGlowDisc(context: context)
            case 172:
                primPoison(context: context)
            case 173:
                primWaveHeightsSlow(context: context)
            default:
                break
            }
        }

        state.stateCnt += 1
        if state.duration > 0 && state.stateCnt > state.duration {
            isAlive = false
        }
    }

    public func collectBatches(
        into collector: inout EffectPrimitiveBatchCollector,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) {
        guard isAlive else {
            return
        }

        if let customRender {
            customRender(self, &collector, world, assets)
            return
        }

        switch id {
        case .pp_2dtexture, .pp_2dtextureorbit:
            render2DPrimitive(into: &collector, assets: assets)
        case .pp_2dquad:
            render2DDiamond(into: &collector, assets: assets)
        case .pp_2dflash:
            render2DFlash(into: &collector, assets: assets)
        case .pp_2dcircle:
            render2DCircle(into: &collector, assets: assets)
        case .pp_3dparticle, .pp_3dparticlegravity, .pp_3dparticleorbit, .pp_3dparticlespline:
            renderSegmentSprites2(into: &collector, assets: assets)
        case .pp_3dquadhorn:
            renderPyramid(into: &collector, assets: assets)
        case .pp_3dspline, .pp_3dspiral:
            renderRecordQuads(into: &collector, assets: assets)
        case .pp_3dcircle:
            renderRecordRings(into: &collector, assets: assets)
        case .pp_3dcylinder:
            renderArcBand(into: &collector, assets: assets)
        case .pp_3dsphere:
            renderSphere(into: &collector, assets: assets)
        case .pp_3dtexture:
            render3DTexture(into: &collector, assets: assets)
        case .pp_3dcrosstexture:
            renderCrossPlanes(into: &collector, assets: assets)
        case .pp_3dparticle_nomaster:
            renderSegmentSprites2(into: &collector, assets: assets)
        case .pp_3dtexture_nomaster:
            render3DTextureNoMaster(into: &collector, assets: assets)
        case .pp_3dflash:
            render3DFlash(into: &collector, assets: assets)
        case .pp_3dline:
            render3DLine(into: &collector)
        case .pp_3dcasting, .pp_3dcasting_2, .pp_3dcasting_3:
            render3DCasting(into: &collector, assets: assets)
        case 26:
            renderSizedSquare(into: &collector, assets: assets)
        case .pp_mapparticle:
            renderGroundBubbles(into: &collector, assets: assets)
        case 28:
            renderSizedSquare(into: &collector, assets: assets)
        case 29:
            renderGroundFog(into: &collector, assets: assets)
        case 30, 31:
            render3DCasting(into: &collector, assets: assets)
        case 32:
            renderLayeredGlow(into: &collector, assets: assets)
        case 33:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_gi_3:
            render3DCasting2(into: &collector, assets: assets)
        case 35:
            renderOrbitIcons(into: &collector, assets: assets, scale: 1.0, red: 100, green: 100, blue: 255)
        case 36:
            render3DCastingLowPolygon(into: &collector, assets: assets)
        case .pp_grandcross2:
            renderGrandCross2(into: &collector, assets: assets)
        case .pp_linelink:
            renderTube(into: &collector, assets: assets)
        case 39:
            renderSizedSquare(into: &collector, assets: assets)
        case .pp_sakura:
            renderSegmentSprites2(into: &collector, assets: assets)
        case 41:
            render3DCasting(into: &collector, assets: assets)
        case .pp_shieldboomerang:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_intimidate:
            renderOrbitSquare(into: &collector, assets: assets)
        case 44:
            renderRotatedPlate(into: &collector, assets: assets)
        case .pp_teihit2:
            renderFieldPanel(into: &collector, assets: assets)
        case 46:
            renderSegmentSprites2(into: &collector, assets: assets)
        case .pp_bottom:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_bottom2:
            renderColorPlane(into: &collector, assets: assets)
        case .pp_bottomout:
            renderFieldPanel(into: &collector, assets: assets)
        case 50:
            render3DCasting(into: &collector, assets: assets)
        case 51:
            renderSegmentSprites2(into: &collector, assets: assets)
        case .pp_pokjuk:
            renderTrailSquares(into: &collector, assets: assets)
        case .pp_throwitem:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_chemicalprotection:
            renderChemical(into: &collector, assets: assets)
        case .pp_chemical2:
            renderFloorRect(into: &collector, assets: assets)
        case .pp_chemical3:
            renderGroundBar(into: &collector, assets: assets)
        case 57:
            render3DCasting(into: &collector, assets: assets)
        case .pp_firstaid:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_particle_up:
            renderFieldPanel(into: &collector, assets: assets)
        case 60:
            render3DCasting(into: &collector, assets: assets)
        case .pp_guard:
            renderSphereCage(into: &collector, assets: assets)
        case .pp_wind:
            renderRiseArc(into: &collector, assets: assets)
        case 63:
            render3DCasting(into: &collector, assets: assets)
        case .pp_rect_up:
            renderRectUp(into: &collector, assets: assets)
        case .pp_3dcasting_4:
            render3DCasting(into: &collector, assets: assets)
        case .pp_forest:
            renderPentagon(into: &collector, assets: assets)
        case 67:
            renderSizedSquare(into: &collector, assets: assets)
        case .pp_asuracasting:
            renderHaloLayers(into: &collector, assets: assets)
        case 69:
            renderPentaRing(into: &collector, assets: assets)
        case .pp_hitline:
            renderHitLine(into: &collector, assets: assets)
        case .pp_blind:
            renderBlind(into: &collector, assets: assets)
        case 72:
            renderGrid(into: &collector, assets: assets)
        case .pp_magnum2:
            renderMagnum2(into: &collector, assets: assets)
        case 74:
            renderHalfSphere2(into: &collector, assets: assets)
        case .pp_slash1:
            renderSlash1(into: &collector, assets: assets)
        case .pp_saintwing:
            renderSaintWing(into: &collector, assets: assets)
        case .pp_spherewind:
            renderSphereWind(into: &collector, assets: assets)
        case .pp_colorpaper:
            renderColorPaper(into: &collector, assets: assets)
        case 79:
            renderScrollColumn(into: &collector, assets: assets)
        case 80:
            renderGroundFog(into: &collector, assets: assets)
        case 81:
            renderBeam(into: &collector, assets: assets)
        case 82:
            renderTeiFacingSlots(into: &collector, assets: assets)
        case .pp_ghost, .pp_superangel:
            renderSegmentSprites2(into: &collector, assets: assets)
        case 86:
            renderFloorSquare(into: &collector, assets: assets)
        case 87:
            renderFieldPanel(into: &collector, assets: assets)
        case 88:
            renderSizedSquare(into: &collector, assets: assets)
        case 89:
            renderFanBeam(into: &collector, assets: assets)
        case .pp_rect_up2:
            renderRectUp2(into: &collector, assets: assets)
        case .pp_spherewind2:
            renderSphereWind(into: &collector, assets: assets)
        case 92:
            renderFloorSquare(into: &collector, assets: assets)
        case .pp_rainbow:
            renderRainbow(into: &collector, assets: assets)
        case .pp_peong:
            renderPeong(into: &collector, assets: assets)
        case .pp_effecttexture2:
            renderTeiFacingSlots(into: &collector, assets: assets)
        case .pp_peongup:
            renderPeongUp(into: &collector, assets: assets)
        case .pp_tanji2:
            renderFieldPanel(into: &collector, assets: assets)
        case 98:
            renderRing(into: &collector, assets: assets)
        case .pp_doublegumgang:
            renderDoubleGumGang(into: &collector, assets: assets)
        case .pp_hitline3:
            renderHitLine3(into: &collector, assets: assets)
        case .pp_electric:
            renderLightningArc(into: &collector, assets: assets)
        case .pp_electric2:
            renderLightningTube(into: &collector, assets: assets)
        case 103:
            renderStackedRings(into: &collector, assets: assets)
        case .pp_halfsphere:
            renderHalfSphere(into: &collector, assets: assets)
        case 105:
            renderCone(into: &collector, assets: assets)
        case .pp_attackenergy2:
            renderAttackEnergy2(into: &collector, assets: assets)
        case .pp_3dcasting_5, .pp_flowercast:
            render3DCasting(into: &collector, assets: assets)
        case .pp_soullink:
            renderSoulLink(into: &collector, assets: assets)
        case .pp_heal_low:
            render3DCastingLowPolygon(into: &collector, assets: assets)
        case .pp_soulparticle:
            renderSoulParticle(into: &collector, assets: assets)
        case 112:
            renderMagicTarget(into: &collector, world: world, assets: assets)
        case 113:
            render3DCasting(into: &collector, assets: assets)
        case .pp_hermode:
            renderHermode(into: &collector, assets: assets)
        case 115:
            renderSoulParticle(into: &collector, assets: assets)
        case .pp_shieldboomerang3:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_3dquadhorn2:
            renderPyramid(into: &collector, assets: assets)
        case .pp_aciddemon:
            render3DCasting(into: &collector, assets: assets)
        case 119:
            renderFloorSquare2(into: &collector, assets: assets)
        case .pp_sma:
            break
        case .pp_sma2:
            renderSMA2(into: &collector, assets: assets)
        case 122:
            renderFloorSquare2(into: &collector, assets: assets)
        case .pp_twilight:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_kouenka:
            renderSegmentSprites2(into: &collector, assets: assets)
        case .pp_stin4:
            renderFloorSquare2(into: &collector, assets: assets)
        case 126:
            renderRotatedRing(into: &collector, assets: assets)
        case .pp_bubble_drop:
            renderFieldPanel(into: &collector, assets: assets)
        case .pp_effecttexture_ani:
            renderTeiFacingSlots(into: &collector, assets: assets)
        case 129:
            renderBobbingRing(into: &collector, assets: assets)
        case 130:
            renderFacingQuads(into: &collector, assets: assets)
        case 131:
            renderRipple(into: &collector, assets: assets)
        case 132:
            renderColorPanel(into: &collector, assets: assets)
        case 133:
            renderSpiralBlades(into: &collector, assets: assets)
        case 134:
            renderBladeTrail(into: &collector, assets: assets)
        case 135:
            renderJitterSweeps(into: &collector, assets: assets)
        case 136:
            renderSpinSquares(into: &collector, assets: assets)
        case 137:
            renderArcWalls(into: &collector, assets: assets)
        case 138:
            renderTwinFacingSquares(into: &collector, assets: assets)
        case 139:
            render3DCasting(into: &collector, assets: assets)
        case 140:
            renderTeiFacingSlots(into: &collector, assets: assets)
        case 141:
            renderTaperedQuad(into: &collector, assets: assets)
        case 142:
            renderStandingPanels(into: &collector, assets: assets)
        case 143:
            renderGroundSquare(into: &collector, assets: assets)
        case 144:
            renderGroundArcStep(into: &collector, assets: assets)
        case 145:
            renderPillarSquares(into: &collector, assets: assets)
        case 146:
            renderTrailingArc(into: &collector, assets: assets)
        case 147:
            renderHaloLayers(into: &collector, assets: assets)
        case 148:
            renderGroundSquareBlend(into: &collector, assets: assets)
        case 149:
            renderGroundArcGlow(into: &collector, assets: assets, usesMinimalEffects: lastUsesMinimalEffects)
        case 150:
            renderHoverSquares(into: &collector, assets: assets)
        case 152:
            renderSegmentSpriteTrail(into: &collector, assets: assets)
        case 153:
            renderSegmentSpriteGlow(into: &collector, assets: assets)
        case 154:
            renderBladeFins(into: &collector, assets: assets)
        case 155:
            renderTwinGlowSquares(into: &collector, assets: assets)
        case 156:
            renderJitterQuads(into: &collector, assets: assets)
        case 157:
            renderGlowSquare(into: &collector, assets: assets)
        case 158:
            renderGroundArc(into: &collector, assets: assets)
        case 159:
            renderBladeQuads(into: &collector, assets: assets)
        case 160:
            renderPolygonFrames(into: &collector, assets: assets)
        case 161:
            renderSizedSquare(into: &collector, assets: assets)
        case 162:
            renderFanSlice(into: &collector, assets: assets)
        case 163:
            renderFanWedge(into: &collector, assets: assets)
        case 164:
            renderFanTrail(into: &collector, assets: assets)
        case 165:
            renderCurvedFanTrail(into: &collector, assets: assets)
        case 166:
            renderFoldingRibbon(into: &collector, assets: assets)
        case 167:
            renderSegmentSprites(into: &collector, assets: assets)
        case 168:
            renderGroundSprite(into: &collector, world: world, assets: assets)
        case 169:
            render3DCastingLowPolygon(into: &collector, assets: assets)
        case 170:
            renderTwinGlowSquares(into: &collector, assets: assets)
        case 171:
            renderGlowDisc(into: &collector, assets: assets)
        case 172:
            renderTintOverlay172(into: &collector, assets: assets)
        case 173:
            renderGroundArc2(into: &collector, assets: assets)
        default:
            break
        }
    }

    // MARK: - Master Following & Animation Helpers

    public func followMaster() {
        if let master {
            position = master.position
        }
    }

    public func tickLiveSlots() {
        for index in 0..<state.slots.count where state.slots[index].life == 1 {
            state.slots[index].process += 1
        }
    }

    public func followMasterAndTickSlots() {
        followMaster()
        tickLiveSlots()
    }

    @discardableResult
    public func followMasterAndAdvance() -> Bool {
        followMaster()
        return animMotion()
    }

    @discardableResult
    public func animMotion() -> Bool {
        let speed = max(1, state.animSpeed)
        guard state.stateCnt % speed == 0 else {
            return true
        }

        let frameCount = max(1, spriteFrameCount)
        currentMotion += 1

        if !state.repeatAnim {
            if (state.pattern & 0x800) != 0 {
                if currentMotion == frameCount {
                    currentMotion -= 1
                }
            } else if currentMotion == frameCount {
                return false
            }
        } else {
            currentMotion %= frameCount
        }

        return true
    }

    // MARK: - Trail Segments (`InitSegment` / `ShiftSegment`)

    public func initSegment() {
        let count = min(max(0, state.numSegment), state.records.count)
        let color = Self.packARGB(
            alpha: Int(state.alpha),
            red: state.red,
            green: state.green,
            blue: state.blue
        )

        for index in 0..<count {
            state.records[index].position = position
            for corner in 0..<4 {
                state.records[index].corners[corner] = state.segPos[corner]
            }
            state.records[index].radius = state.radius
            state.records[index].scale = state.size
            state.records[index].angle = state.longitude
            state.records[index].transform = state.transform
            state.records[index].alpha = state.alpha
            state.records[index].red = state.red
            state.records[index].green = state.green
            state.records[index].blue = state.blue
            state.records[index].color = color
        }
    }

    public func shiftSegment() {
        let count = min(max(1, state.numSegment), state.records.count)

        if count > 1 {
            let alphaStep = state.alpha / Float(count)
            let sizeStep = state.size / Float(count)

            for index in stride(from: count - 1, through: 1, by: -1) {
                state.records[index].position = state.records[index - 1].position
                for corner in 0..<4 {
                    state.records[index].corners[corner] = state.records[index - 1].corners[corner]
                }
                state.records[index].radius = state.records[index - 1].radius
                state.records[index].angle = state.records[index - 1].angle
                state.records[index].transform = state.records[index - 1].transform

                let segmentAlpha = state.alpha - Float(index) * alphaStep
                state.records[index].alpha = segmentAlpha
                state.records[index].color = Self.packARGB(
                    alpha: Int(segmentAlpha),
                    red: state.red,
                    green: state.green,
                    blue: state.blue
                )
                state.records[index].scale = state.size - Float(index) * sizeStep * 0.5
            }
        }

        state.records[0].position = position
        for corner in 0..<4 {
            state.records[0].corners[corner] = state.segPos[corner]
        }
        state.records[0].radius = state.radius
        state.records[0].scale = state.size
        state.records[0].angle = state.longitude
        state.records[0].transform = state.transform
        state.records[0].alpha = state.alpha
        state.records[0].color = Self.packARGB(
            alpha: Int(state.alpha),
            red: state.red,
            green: state.green,
            blue: state.blue
        )
    }

    // MARK: - Alpha & Color Processing (`ProcessAlpha` / `GetColorOverride`)

    public func processAlpha() {
        if state.alphaCycle != 0 {
            if !state.chPoint.isEmpty {
                var index = state.colorCycleIndex
                if index < 0 || index >= state.chPoint.count {
                    state.colorCycleIndex = 0
                    index = 0
                }
                if Float(state.stateCnt) == state.chPoint[index] {
                    if index < state.chVal1.count {
                        state.alpha = state.chVal1[index]
                    }
                    if index < state.chVal2.count {
                        state.maxAlpha = state.chVal2[index]
                    }
                    state.colorCycleIndex = index + 1
                }
            }
            limitAlpha()
        } else {
            if state.alphaSpeedCycle != 0 && !state.chPoint.isEmpty {
                var index = state.colorCycleIndex
                if index < 0 || index >= state.chPoint.count {
                    state.colorCycleIndex = 0
                    index = 0
                }
                if Float(state.stateCnt) == state.chPoint[index] {
                    if index < state.chVal1.count {
                        state.alphaSpeed = state.chVal1[index]
                    }
                    state.colorCycleIndex = index + 1
                }
            }
            limitAlpha()
        }

        if state.stateCnt == state.fadeOutCnt {
            state.pattern &= ~0x80
            let remaining = state.duration - state.stateCnt
            if remaining != 0 {
                state.alphaSpeed = -(state.alpha / Float(remaining)) * state.alphaDelta
            }
        }

        let sum = state.alphaSpeed + state.alpha
        let clamped = min(state.maxAlpha, max(state.minAlpha, sum))
        state.alpha = clamped
        state.argb = Self.packARGB(
            alpha: Int(clamped),
            red: state.red,
            green: state.green,
            blue: state.blue
        )
    }

    private func limitAlpha() {
        if (state.pattern & 0x80) != 0 {
            if state.alphaSpeed < 0 {
                if state.alpha <= state.minAlpha {
                    state.alphaSpeed *= -1
                }
            } else if state.alpha >= state.maxAlpha {
                state.alphaSpeed *= -1
            }
        }

        if !state.isDisappear, let master {
            let primitiveRemaining = state.duration - state.stateCnt
            let masterRemaining = master.duration - master.stateCnt
            if primitiveRemaining > masterRemaining + 1 {
                state.isDisappear = true
                state.pattern &= ~0x80
                if masterRemaining > 0 {
                    state.alphaSpeed = -(state.alpha / Float(masterRemaining))
                } else {
                    state.alphaSpeed = -state.alpha
                }
            }
        }
    }

    public func colorOverride(red: inout UInt8, green: inout UInt8, blue: inout UInt8) {
        guard let master else {
            return
        }
        if master.colorChannels[0] != -1 {
            red = UInt8(truncatingIfNeeded: master.colorChannels[0])
        }
        if master.colorChannels[1] != -1 {
            green = UInt8(truncatingIfNeeded: master.colorChannels[1])
        }
        if master.colorChannels[2] != -1 {
            blue = UInt8(truncatingIfNeeded: master.colorChannels[2])
        }
    }

    // MARK: - Orientation & Camera-Facing Helpers (`Get_Angle` / `FaceCamera` / `Tei_TowardScreen`)

    public static func angle(dx: Float, dy: Float) -> Int16 {
        let length = sqrtf(dx * dx + dy * dy)
        guard length > 0 else {
            return 0
        }

        let normalX = dx / length
        let normalY = dy / length

        for index in 0...180 {
            if normalX >= EffectSpace.cosTable[index] {
                return normalY >= 0 ? Int16(index) : Int16(360 - index)
            }
        }

        return 180
    }

    public func faceCamera(world: any EffectWorldContext) {
        let yaw = Int(world.cameraYawDegrees)
        let pitch = Int(world.cameraPitchDegrees)

        state.slots[0].alphaT = Int16(((360 - yaw) % 360 + 360) % 360)
        state.slots[1].alphaT = Int16(((360 - pitch + 90) % 360 + 360) % 360)
    }

    public static func towardScreen(
        _ v1: inout SIMD3<Float>,
        _ v2: inout SIMD3<Float>,
        _ v3: inout SIMD3<Float>,
        _ v4: inout SIMD3<Float>,
        rot0: Int16,
        rot1: Int16
    ) {
        rotatePairX(&v1, angle: Int(rot1))
        rotatePairX(&v2, angle: Int(rot1))
        rotatePairX(&v3, angle: Int(rot1))
        rotatePairX(&v4, angle: Int(rot1))
        rotatePairY(&v1, angle: Int(rot0))
        rotatePairY(&v2, angle: Int(rot0))
        rotatePairY(&v3, angle: Int(rot0))
        rotatePairY(&v4, angle: Int(rot0))
    }

    private static func rotatePairX(_ point: inout SIMD3<Float>, angle: Int) {
        let cosValue = EffectSpace.cosine(degrees: angle)
        let sinValue = EffectSpace.sine(degrees: angle)
        let y = point.y
        let z = point.z
        point.z = z * cosValue - y * sinValue
        point.y = y * cosValue + z * sinValue
    }

    private static func rotatePairY(_ point: inout SIMD3<Float>, angle: Int) {
        let cosValue = EffectSpace.cosine(degrees: angle)
        let sinValue = EffectSpace.sine(degrees: angle)
        let x = point.x
        let z = point.z
        point.x = x * cosValue - z * sinValue
        point.z = z * cosValue + x * sinValue
    }

    // MARK: - Core Quad Submission (`RenderTeiRect` Overloads)

    /// Full `RenderTeiRect` overload with explicit color, blend selector, texture index, UV bounds, and depth mode.
    public func renderTeiRect(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        alpha: Int16,
        v1: SIMD3<Float>,
        v2: SIMD3<Float>,
        v3: SIMD3<Float>,
        v4: SIMD3<Float>,
        blendSelector pw: Int16,
        textureIndex: Int,
        isWorldPosition: Bool,
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        v1Coord: Float = 0,
        v2Coord: Float = 1,
        u1Coord: Float = 0,
        u2Coord: Float = 1,
        extra: Int8 = 0
    ) {
        var finalRed = red
        var finalGreen = green
        var finalBlue = blue
        colorOverride(red: &finalRed, green: &finalGreen, blue: &finalBlue)

        let defaultDstBlend: Int32 = pw != 0 ? 6 : 2
        let masterDstBlend = master?.colorChannels[3] ?? -1
        let resolvedDstBlend = masterDstBlend != -1 ? masterDstBlend : defaultDstBlend

        let srcBlend: EffectBlendFactor
        let dstBlend: EffectBlendFactor
        if pw == 10 {
            srcBlend = .one
            dstBlend = .zero
        } else {
            srcBlend = .sourceAlpha
            if pw == 99 {
                dstBlend = .oneMinusSourceAlpha
            } else {
                dstBlend = EffectBlendFactor(d3dBlend: resolvedDstBlend)
            }
        }

        let offset = isWorldPosition ? SIMD3<Float>.zero : position
        let p0 = v1 + offset
        let p1 = v2 + offset
        let p2 = v3 + offset
        let p3 = v4 + offset

        let color = Self.normalizedRGBA(alpha: alpha, red: finalRed, green: finalGreen, blue: finalBlue)
        let renderState = EffectPrimitiveRenderState(srcBlend: srcBlend, dstBlend: dstBlend, extra: extra)
        let texture = resolveTexture(at: textureIndex, assets: assets)
        let center = (p0 + p1 + p2 + p3) * 0.25

        collector.appendEffectQuad(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            uv0: SIMD2<Float>(u1Coord, v2Coord),
            uv1: SIMD2<Float>(u2Coord, v2Coord),
            uv2: SIMD2<Float>(u2Coord, v1Coord),
            uv3: SIMD2<Float>(u1Coord, v1Coord),
            color0: color,
            color1: color,
            color2: color,
            color3: color,
            texture: texture,
            renderState: renderState,
            effectCenter: center
        )
    }

    /// Palette-driven `RenderTeiRect` overload mapping `state.size` to color/blend and slicing U horizontally by `texPart / 21`.
    public func renderTeiRect(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        texPart: Int,
        alphaB: Int16,
        alphaT: Int16,
        v1: SIMD3<Float>,
        v2: SIMD3<Float>,
        v3: SIMD3<Float>,
        v4: SIMD3<Float>,
        textureIndex: Int,
        sizeOverride: Float? = nil
    ) {
        let palette = SizePalette(sizeKey: Int(sizeOverride ?? state.size))
        let effectiveAlpha = palette.alphaOverride ?? alphaB

        var finalRed = palette.red
        var finalGreen = palette.green
        var finalBlue = palette.blue
        colorOverride(red: &finalRed, green: &finalGreen, blue: &finalBlue)

        let masterDstBlend = master?.colorChannels[3] ?? -1
        let resolvedDstBlend = masterDstBlend != -1 ? masterDstBlend : palette.dstBlend

        let left: Float
        let right: Float
        if texPart >= 100 {
            if texPart == 100 {
                left = 0.35
                right = 0.45
            } else if texPart == 101 {
                left = 0.45
                right = 0.55
            } else {
                left = 0.55
                right = 0.65
            }
        } else {
            left = texPart == 0 ? 0 : Float(texPart) / 21.0
            right = Float(texPart + 1) / 21.0
        }

        let p0 = v1 + position
        let p1 = v2 + position
        let p2 = v3 + position
        let p3 = v4 + position

        let color = Self.normalizedRGBA(alpha: effectiveAlpha, red: finalRed, green: finalGreen, blue: finalBlue)
        let renderState = EffectPrimitiveRenderState(
            srcBlend: .sourceAlpha,
            dstBlend: EffectBlendFactor(d3dBlend: resolvedDstBlend)
        )
        let texture = resolveTexture(at: textureIndex, assets: assets)
        let center = (p0 + p1 + p2 + p3) * 0.25

        collector.appendEffectQuad(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            uv0: SIMD2<Float>(left, palette.textureV),
            uv1: SIMD2<Float>(right, palette.textureV),
            uv2: SIMD2<Float>(right, 0),
            uv3: SIMD2<Float>(left, 0),
            color0: color,
            color1: color,
            color2: color,
            color3: color,
            texture: texture,
            renderState: renderState,
            effectCenter: center
        )
    }

    /// Custom-RGB `RenderTeiRect` overload slicing V vertically by `texPart / 21`.
    public func renderTeiRect(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        texPart: Int,
        alphaB: Int16,
        alphaT: Int16,
        v1: SIMD3<Float>,
        v2: SIMD3<Float>,
        v3: SIMD3<Float>,
        v4: SIMD3<Float>,
        blendSelector pw: Int8,
        red: UInt8,
        green: UInt8,
        blue: UInt8
    ) {
        var finalRed = red
        var finalGreen = green
        var finalBlue = blue
        colorOverride(red: &finalRed, green: &finalGreen, blue: &finalBlue)

        let defaultDstBlend: Int32 = pw != 0 ? 6 : 2
        let masterDstBlend = master?.colorChannels[3] ?? -1
        let resolvedDstBlend = masterDstBlend != -1 ? masterDstBlend : defaultDstBlend

        let top: Float = texPart == 0 ? 0 : Float(texPart) / 21.0
        let bottom: Float = Float(texPart + 1) / 21.0

        let p0 = v1 + position
        let p1 = v2 + position
        let p2 = v3 + position
        let p3 = v4 + position

        let color = Self.normalizedRGBA(alpha: alphaB, red: finalRed, green: finalGreen, blue: finalBlue)
        let renderState = EffectPrimitiveRenderState(
            srcBlend: .sourceAlpha,
            dstBlend: EffectBlendFactor(d3dBlend: resolvedDstBlend)
        )
        let texture = resolveTexture(at: 0, assets: assets)
        let center = (p0 + p1 + p2 + p3) * 0.25

        collector.appendEffectQuad(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            uv0: SIMD2<Float>(1, top),
            uv1: SIMD2<Float>(1, bottom),
            uv2: SIMD2<Float>(0, bottom),
            uv3: SIMD2<Float>(0, top),
            color0: color,
            color1: color,
            color2: color,
            color3: color,
            texture: texture,
            renderState: renderState,
            effectCenter: center
        )
    }

    public func resolveTexture(at index: Int, assets: EffectAssetStore?) -> (any MTLTexture)? {
        guard let assets, index >= 0, index < state.texturePaths.count else {
            return nil
        }
        return assets.texture(atPath: state.texturePaths[index])
    }

    // MARK: - Internal Utilities

    @inlinable
    static func packARGB(alpha: Int, red: Int, green: Int, blue: Int) -> UInt32 {
        let a = UInt32(truncatingIfNeeded: alpha) & 0xFF
        let r = UInt32(truncatingIfNeeded: red) & 0xFF
        let g = UInt32(truncatingIfNeeded: green) & 0xFF
        let b = UInt32(truncatingIfNeeded: blue) & 0xFF
        return (a << 24) | (r << 16) | (g << 8) | b
    }

    @inlinable
    static func normalizedRGBA(alpha: Int16, red: UInt8, green: UInt8, blue: UInt8) -> SIMD4<Float> {
        let clampedAlpha = max(0, min(255, Int(alpha)))
        return SIMD4<Float>(
            Float(red) / 255.0,
            Float(green) / 255.0,
            Float(blue) / 255.0,
            Float(clampedAlpha) / 255.0
        )
    }

    private struct SizePalette {
        var red: UInt8
        var green: UInt8
        var blue: UInt8
        var dstBlend: Int32
        var textureV: Float
        var alphaOverride: Int16?

        private init(
            red: UInt8 = 255,
            green: UInt8 = 255,
            blue: UInt8 = 255,
            dstBlend: Int32 = 2,
            textureV: Float = 1.0,
            alphaOverride: Int16? = nil
        ) {
            self.red = red
            self.green = green
            self.blue = blue
            self.dstBlend = dstBlend
            self.textureV = textureV
            self.alphaOverride = alphaOverride
        }

        init(sizeKey: Int) {
            self = switch sizeKey {
            case 0: SizePalette(dstBlend: 6)
            case 1: SizePalette(red: 255, green: 175, blue: 175)
            case 2: SizePalette(red: 195, green: 195, blue: 255, dstBlend: 6)
            case 3: SizePalette(dstBlend: 6, alphaOverride: 80)
            case 4: SizePalette(red: 100, green: 100, blue: 255)
            case 6: SizePalette(red: 255, green: 100, blue: 100)
            case 7: SizePalette(red: 100, green: 255, blue: 100)
            case 8: SizePalette(red: 255, green: 255, blue: 170)
            case 9: SizePalette(red: 140, green: 210, blue: 140)
            case 10: SizePalette(red: 255, green: 89, blue: 182)
            case 11: SizePalette(red: 170, green: 170, blue: 255)
            case 12: SizePalette(red: 50, green: 50, blue: 50, dstBlend: 6)
            case 13: SizePalette(red: 255, green: 50, blue: 255, dstBlend: 6)
            case 14: SizePalette(red: 120, green: 120, blue: 255, dstBlend: 6)
            case 15: SizePalette(red: 10, green: 255, blue: 10)
            case 16: SizePalette(red: 20, green: 255, blue: 20)
            case 17: SizePalette(red: 0, green: 0, blue: 255)
            case 18: SizePalette(red: 255, green: 0, blue: 0)
            case 19: SizePalette(red: 0, green: 255, blue: 0)
            case 20: SizePalette(red: 255, green: 255, blue: 0)
            case 21: SizePalette(red: 255, green: 0, blue: 255)
            case 22: SizePalette(red: 0, green: 255, blue: 255)
            case 23: SizePalette(red: 41, green: 94, blue: 188, dstBlend: 6)
            case 24: SizePalette(red: 10, green: 66, blue: 114)
            case 25: SizePalette(red: 35, green: 146, blue: 185)
            case 26: SizePalette(red: 164, green: 205, blue: 254)
            case 27: SizePalette(red: 84, green: 169, blue: 205)
            case 28: SizePalette(red: 108, green: 26, blue: 255)
            case 29: SizePalette(red: 177, green: 255, blue: 58)
            case 30: SizePalette(red: 85, green: 30, blue: 185)
            case 31: SizePalette(red: 244, green: 187, blue: 124)
            case 32: SizePalette(red: 0, green: 0, blue: 0, dstBlend: 6)
            case 40: SizePalette(red: 70, green: 70, blue: 255)
            case 41: SizePalette(red: 30, green: 30, blue: 255)
            case 42: SizePalette(red: 43, green: 40, blue: 46, dstBlend: 6)
            case 43: SizePalette(red: 125, green: 182, blue: 160, dstBlend: 6)
            case 44: SizePalette(red: 180, green: 55, blue: 30, dstBlend: 6)
            case 45: SizePalette(red: 65, green: 141, blue: 231)
            case 46: SizePalette(red: 164, green: 47, blue: 29)
            case 47: SizePalette(red: 172, green: 154, blue: 56)
            case 48: SizePalette(red: 80, green: 20, blue: 20)
            case 49: SizePalette(red: 200, green: 130, blue: 84)
            case 50: SizePalette(red: 255, green: 198, blue: 91)
            case 100: SizePalette(red: 250, green: 250, blue: 255, dstBlend: 6, textureV: 0.9)
            default: SizePalette()
            }
        }
    }
}

extension EffectPrimitiveRenderState {
    init(
        srcBlend: EffectBlendFactor,
        dstBlend: EffectBlendFactor,
        extra: Int8
    ) {
        let depthTest: Bool
        let depthBias: Float
        if extra == 1 || extra == 3 {
            depthTest = false
            depthBias = 0
        } else if extra == 2 {
            depthTest = true
            depthBias = 0.05
        } else {
            depthTest = true
            depthBias = 0
        }

        self.init(
            srcBlend: srcBlend,
            dstBlend: dstBlend,
            depthTest: depthTest,
            depthWrite: false,
            cullMode: .none,
            bucket: .translucent,
            depthBias: depthBias
        )
    }
}
