//
//  MapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/30.
//

import RealityKit
import SGLMath
import SwiftUI
import ThumbstickView

struct MapView: View {
    var scene: MapScene

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
            Text("Game")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            #else
            MapSceneView(scene: scene)
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
            ZStack {
                MainActionButton("A", color: .red) {
                    scene.attackNearestMonster()
                }

                SubActionButton("P", color: .green, angle: 75) {
                    scene.pickUpNearestItem()
                }

                SubActionButton("T", color: .blue, angle: 15) {
                    scene.talkToNearestNPC()
                }
            }
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
                case .inventory:
                    InventoryView(inventory: gameSession.inventory)
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
}

private struct MainActionButton: View {
    var title: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.75))
                    .frame(width: 72, height: 72)
                    .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 2)

                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }
        }
    }

    init(_ title: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }
}

private struct SubActionButton: View {
    var title: String
    var color: Color
    var angle: CGFloat
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.75))
                    .frame(width: 56, height: 56)
                    .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 2)

                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
        }
        .offset(x: -80 * sin(radians(angle)), y: -80 * cos(radians(angle)))
    }

    init(_ title: String, color: Color, angle: CGFloat, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.angle = angle
        self.action = action
    }
}
