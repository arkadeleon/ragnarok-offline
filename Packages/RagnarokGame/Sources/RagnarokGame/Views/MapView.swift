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
        #if os(visionOS)
        .onAppear {
            Task {
                await openImmersiveSpace(id: gameSession.immersiveSpaceID)
            }
        }
        #endif
        .overlay(alignment: .topLeading) {
            if let char = gameSession.char, let status = gameSession.playerStatus {
                VStack(alignment: .leading, spacing: 0) {
                    BasicInfoView(char: char, status: status)

                    MenuView { item in
                        if item == presentedMenuItem {
                            presentedMenuItem = nil
                        } else {
                            presentedMenuItem = item
                        }
                    }

                    if let presentedMenuItem {
                        switch presentedMenuItem {
                        case .status:
                            StatusView(status: status)
                        case .inventory:
                            InventoryView(inventory: gameSession.inventory)
                        case .options:
                            OptionsView()
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            ChatBoxView()
        }
        .overlay(alignment: .bottomTrailing) {
            ZStack {
                ThumbstickView(updatingValue: $movementValue, radius: 60)
                    .onReceive(timer) { _ in
                        scene.onMovementValueChanged(movementValue: movementValue)
                    }

                ActionButton("A", color: .red, angle: 0) {
                    scene.attackNearestMonster()
                }

                ActionButton("P", color: .green, angle: 45) {
                    scene.pickUpNearestItem()
                }

                ActionButton("T", color: .blue, angle: 90) {
                    scene.talkToNearestNPC()
                }
            }
            .padding()
        }
        .overlay {
            NPCDialogOverlayView()
        }
    }
}

private struct ActionButton: View {
    var title: String
    var color: Color
    var angle: CGFloat
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.75))
                    .frame(width: 48, height: 48)
                    .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 2)

                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
        }
        .offset(x: -96 * sin(radians(angle)), y: -96 * cos(radians(angle)))
    }

    init(_ title: String, color: Color, angle: CGFloat, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.angle = angle
        self.action = action
    }
}
