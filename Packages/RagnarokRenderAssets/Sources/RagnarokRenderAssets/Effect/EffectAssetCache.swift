//
//  EffectAssetCache.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/8/25.
//

/// The current phase of an effect resource loading operation.
enum EffectAssetPhase {
    case inProgress(Task<any Sendable, any Error>)
    case success(any Sendable)
    case failure(any Error)

    var resource: any Sendable {
        get async throws {
            switch self {
            case .inProgress(let task):
                try await task.value
            case .success(let resource):
                resource
            case .failure(let error):
                throw error
            }
        }
    }
}

actor EffectAssetCache {
    private var resources: [String : EffectAssetPhase] = [:]

    func resource<R>(
        forIdentifier resourceIdentifier: String,
        loadOperation: sending @escaping () async throws -> R
    ) async throws -> R where R: Sendable {
        if let phase = resources[resourceIdentifier] {
            return try await phase.resource as! R
        }

        let task = Task<any Sendable, any Error> {
            try await loadOperation()
        }

        resources[resourceIdentifier] = .inProgress(task)

        do {
            let resource = try await task.value
            resources[resourceIdentifier] = .success(resource)
            return resource as! R
        } catch {
            resources[resourceIdentifier] = .failure(error)
            throw error
        }
    }

    func clear() {
        resources.removeAll()
    }
}
