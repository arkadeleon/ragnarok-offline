//
//  MapSceneView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import SwiftUI
import ThumbstickView

struct MapSceneView: View {
    var runtime: MapSceneRuntime

    #if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    #endif

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var screenWidth: CGFloat = 320
    @State private var chatBoxOffsetY: CGFloat = 0
    @State private var presentedMenuItem: MenuItem?
    @State private var movementValue: CGPoint = .zero

    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            #if os(visionOS)
            Color.clear
                .onAppear {
                    Task {
                        await openImmersiveSpace(id: GameSession.immersiveSpaceID)
                    }
                }
                .onDisappear {
                    Task {
                        await dismissImmersiveSpace()
                    }
                }
            #else
            MapView(runtime: runtime)
            #endif
        }
        .overlay(alignment: .bottomLeading) {
            #if os(iOS)
            ThumbstickView(value: $movementValue)
                .padding(.leading, 16)
                .padding(.bottom, isWidescreen ? 16 : ChatBoxView.contentHeight(for: .compact) + 16)
                .onReceive(timer) { _ in
                    runtime.scene.handleMovement(movementValue)
                }
            #elseif os(macOS)
            ChatBoxView()
                .frame(width: 440)
            #endif
        }
        .overlay(alignment: .bottomTrailing) {
            ActionControlPadView(
                onAttack: {
                    runtime.scene.attackNearestMonster()
                },
                onPickup: {
                    runtime.scene.pickUpNearestItem()
                },
                onSkill: { skill in
                    runtime.scene.useSkillOnNearestMonster(skill)
                }
            )
            .padding(.trailing, 16)
            .padding(.bottom, isWidescreen ? 16 : ChatBoxView.contentHeight(for: .compact) + 16)
        }
        .overlay(alignment: .topLeading) {
            if let character = gameSession.character {
                VStack(alignment: .leading, spacing: 0) {
                    BasicInfoView(character: character, status: gameContext.playerStatus)

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
            MinimapView(scene: runtime.scene)
                .padding(.top, 16)
                .padding(.trailing, 16)
        }
        .overlay(alignment: .bottom) {
            #if os(iOS)
            ChatBoxView()
                .frame(width: chatBoxWidth)
                .offset(y: chatBoxOffsetY)
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
                    StatusView(status: gameContext.playerStatus) {
                        presentedMenuItem = nil
                    }
                case .equipment:
                    EquipmentView {
                        presentedMenuItem = nil
                    }
                case .inventory:
                    InventoryView(inventory: gameContext.inventory) {
                        presentedMenuItem = nil
                    }
                case .skill:
                    SkillListView(skillList: gameContext.skillList) {
                        presentedMenuItem = nil
                    }
                case .worldMap:
                    WorldMapView(currentMapName: runtime.scene.mapName) {
                        presentedMenuItem = nil
                    }
                case .options:
                    OptionsView(isPlayerDead: runtime.scene.state.isPlayerDead) {
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
        .onChange(of: runtime.scene.state.isPlayerDead) { _, newValue in
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
