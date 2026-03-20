//
//  MapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/30.
//

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
            MapRenderHost(scene: scene, configuration: renderConfiguration) { projector in
                updateOverlay(projector: projector)
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
                    let intent = MapInputIntent(movementValue: movementValue)
                    scene.handle(intent)
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
    private func updateOverlay(projector: any MapProjector) {
        var gauges: [UInt32: MapSceneOverlay.Gauge] = [:]

        for anchor in scene.state.overlaySnapshot.anchors.values {
            guard let gaugePosition = anchor.gaugePosition,
                  let screenPoint = projector.project(gaugePosition) else {
                continue
            }

            let gauge = MapSceneOverlay.Gauge(
                objectID: anchor.id,
                hp: anchor.hp,
                maxHp: anchor.maxHp,
                sp: anchor.sp,
                maxSp: anchor.maxSp,
                objectType: anchor.objectType,
                screenPosition: screenPoint
            )

            gauges[anchor.id] = gauge
        }

        gameSession.overlay.gauges = gauges
    }
    #endif
}
