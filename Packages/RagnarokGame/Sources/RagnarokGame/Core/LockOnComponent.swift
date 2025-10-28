//
//  LockOnComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/28.
//

import Combine
import RealityKit

struct LockOnComponent: Component {
    var targetEntity: Entity
    var attackRange: Float
    var action: () -> Void
}

final class LockOnSystem: System {
    var subscriptions: [AnyCancellable] = []

    init(scene: Scene) {
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
