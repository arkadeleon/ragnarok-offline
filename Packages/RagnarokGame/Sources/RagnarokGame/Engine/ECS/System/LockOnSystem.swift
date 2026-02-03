//
//  LockOnSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/2/3.
//

import Combine
import RealityKit

class LockOnSystem: System {
    var subscriptions: [AnyCancellable] = []

    required init(scene: Scene) {
        scene.subscribe(
            to: ComponentEvents.WillRemove.self,
            componentType: WalkingComponent.self,
            willRemoveComponent(_:)
        )
        .store(in: &subscriptions)
    }

    @MainActor
    func willRemoveComponent(_ event: ComponentEvents.WillRemove) {
        if let lockOnComponent = event.entity.components[LockOnComponent.self] {
            Task {
                try await Task.sleep(for: .milliseconds(50))
                lockOnComponent.action()
                event.entity.components.remove(LockOnComponent.self)
            }
        }
    }
}
