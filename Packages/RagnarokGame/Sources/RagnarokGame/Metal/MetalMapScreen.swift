//
//  MetalMapScreen.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if !os(visionOS)

import SwiftUI
import ThumbstickView

struct MetalMapScreen: View {
    var scene: MetalMapScene

    @Environment(GameSession.self) private var gameSession

    @State private var screenWidth: CGFloat = 320
    @State private var chatBoxOffsetY: CGFloat = 0
    @State private var presentedMenuItem: MenuItem?
    @State private var movementValue: CGPoint = .zero

    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            MetalMapView(scene: scene)
                .overlay {
                    MapOverlayView(overlay: scene.state.overlay)
                }
        }
        .overlay(alignment: .bottomLeading) {
            ThumbstickView(updatingValue: $movementValue, radius: 72)
                .padding(.leading, 16)
                .padding(.bottom, isWidescreen ? 16 : ChatBoxView.contentHeight(for: .compact) + 16)
                .onReceive(timer) { _ in
                    scene.handleMovement(movementValue)
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
            if let item = presentedMenuItem {
                switch item {
                case .status:
                    StatusView(status: gameSession.playerStatus) {
                        presentedMenuItem = nil
                    }
                case .equipment:
                    EquipmentView {
                        presentedMenuItem = nil
                    }
                case .inventory:
                    InventoryView(inventory: gameSession.inventory) {
                        presentedMenuItem = nil
                    }
                case .skill:
                    SkillListView(skillList: gameSession.skillList) {
                        presentedMenuItem = nil
                    }
                case .options:
                    OptionsView {
                        presentedMenuItem = nil
                    }
                }
            }
        }
        .overlay(alignment: .center) {
            if let dialog = gameSession.dialog {
                NPCDialogView(dialog: dialog)
            }
        }
        .onChange(of: scene.state.isPlayerDead) { _, newValue in
            if newValue {
                presentedMenuItem = .options
            }
        }
        .ignoresSafeArea()
        .onGeometryChange(for: CGFloat.self) { geometryProxy in
            geometryProxy.size.width + geometryProxy.safeAreaInsets.leading + geometryProxy.safeAreaInsets.trailing
        } action: { containerWidth in
            self.screenWidth = containerWidth
        }
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
}

#endif
