//
//  MapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/30.
//

import RealityKit
import SwiftUI
import ThumbstickView

struct MapView: View {
    var scene: MapScene
    var renderConfiguration: MapRenderConfiguration = .default

    @Environment(GameSession.self) private var gameSession

    #if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    #endif

    @State private var screenWidth: CGFloat = 320
    @State private var chatBoxOffsetY: CGFloat = 0
    @State private var presentedMenuItem: MenuItem?
    @State private var movementValue: CGPoint = .zero

    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            #if os(visionOS)
            MapRenderHost(scene: scene, configuration: renderConfiguration)
            #else
            MapRenderHost(scene: scene, configuration: renderConfiguration) { arView in
                updateOverlay(arView: arView)
            }
            .overlay {
                MapSceneOverlayView(overlay: gameSession.overlay)
            }
            #endif
        }
        .overlay(alignment: .bottomLeading) {
            ThumbstickView(updatingValue: $movementValue, radius: 72)
                .padding(.leading, 16)
                .padding(.bottom, isWidescreen ? 16 : ChatBoxView.contentHeight(for: .compact) + 16)
                .onReceive(timer) { _ in
                    scene.onMovementValueChanged(movementValue: movementValue)
                }
        }
        .overlay(alignment: .bottomTrailing) {
            ActionControlPadView(
                onAttack: {
                    scene.attackNearestMonster()
                },
                onPickup: {
                    scene.pickUpNearestItem()
                },
                onTalk: {
                    scene.talkToNearestNPC()
                },
                onSkill: { skill in
                    scene.useSkillOnNearestMonster(skill)
                }
            )
            .padding(.trailing, 16)
            .padding(.bottom, isWidescreen ? 16 : ChatBoxView.contentHeight(for: .compact) + 16)
        }
        .overlay(alignment: .topLeading) {
            if let character = gameSession.character {
                VStack(alignment: .leading, spacing: 0) {
                    BasicInfoView(character: character, status: gameSession.playerStatus)

                    MenuView { item in
                        if item == presentedMenuItem {
                            presentedMenuItem = nil
                        } else {
                            presentedMenuItem = item
                        }
                    }
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // Minimap
        }
        .overlay(alignment: .bottom) {
            ChatBoxView()
                .frame(width: chatBoxWidth)
                .offset(y: chatBoxOffsetY)
                #if os(iOS)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                    let frameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
                    let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt

                    guard let frameEnd, let animationDuration, let animationCurve else {
                        return
                    }

                    let screenHeight = UIScreen.main.bounds.height
                    withAnimation(.keyboard(curve: animationCurve, duration: animationDuration)) {
                        if frameEnd.minY < screenHeight {
                            let keyboardHeight = screenHeight - frameEnd.minY
                            chatBoxOffsetY = ChatBoxView.contentHeight(for: .full) - keyboardHeight
                        } else {
                            chatBoxOffsetY = 0
                        }
                    }
                }
                #endif
        }
        .overlay(alignment: .center) {
            if let presentedMenuItem {
                switch presentedMenuItem {
                case .status:
                    StatusView(status: gameSession.playerStatus)
                case .equipment:
                    EquipmentView()
                case .inventory:
                    InventoryView(inventory: gameSession.inventory)
                case .skill:
                    SkillListView(skillList: gameSession.skillList)
                case .options:
                    OptionsView()
                }
            }
        }
        .overlay(alignment: .center) {
            if let dialog = gameSession.dialog {
                NPCDialogView(dialog: dialog)
            }
        }
        .ignoresSafeArea()
        .onGeometryChange(for: CGFloat.self) { geometryProxy in
            geometryProxy.size.width + geometryProxy.safeAreaInsets.leading + geometryProxy.safeAreaInsets.trailing
        } action: { containerWidth in
            self.screenWidth = containerWidth
        }
        #if os(visionOS)
        .onAppear {
            Task {
                await openImmersiveSpace(id: gameSession.immersiveSpaceID)
            }
        }
        #endif
    }

    private var isUltraWidescreen: Bool {
        screenWidth >= 780
    }

    private var isWidescreen: Bool {
        screenWidth >= 640
    }

    private var chatBoxWidth: CGFloat {
        if isUltraWidescreen {
            360
        } else if isWidescreen {
            280
        } else {
            screenWidth - 16 * 2
        }
    }

    #if !os(visionOS)
    private func updateOverlay(arView: ARView) {
        var gauges: [UInt32: MapSceneOverlay.Gauge] = [:]

        let query = EntityQuery(where: .has(HealthPointsComponent.self))
        for entity in arView.scene.performQuery(query) {
            guard let mapObject = entity.components[MapObjectComponent.self]?.mapObject,
                  let healthPointsComponent = entity.components[HealthPointsComponent.self] else {
                continue
            }

            let worldPosition = entity.position(relativeTo: nil)
            let gaugePosition = worldPosition + [0, -0.8, 0]

            guard var screenPoint = arView.project(gaugePosition) else {
                continue
            }

            #if os(macOS)
            screenPoint.y = arView.bounds.height - screenPoint.y
            #endif

            let spellPointsComponent = entity.components[SpellPointsComponent.self]

            let gauge = MapSceneOverlay.Gauge(
                objectID: mapObject.objectID,
                screenPosition: screenPoint,
                hp: healthPointsComponent.hp,
                maxHp: healthPointsComponent.maxHp,
                sp: spellPointsComponent?.sp,
                maxSp: spellPointsComponent?.maxSp,
                objectType: mapObject.type
            )

            gauges[mapObject.objectID] = gauge
        }

        gameSession.overlay.gauges = gauges
    }
    #endif
}
