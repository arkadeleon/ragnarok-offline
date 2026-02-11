//
//  ThrowingResourceCache.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/2/11.
//

typealias ThrowingResourceTask<R: Resource> = Task<R, any Error>

/// The current phase of an error-throwing resource loading operation.
enum ThrowingResourcePhase<R: Resource> {
    case inProgress(ThrowingResourceTask<R>)
    case success(R)
    case failure(any Error)

    var resource: R {
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

actor ThrowingResourceCache<R: Resource> {
    private var resources: [String : ThrowingResourcePhase<R>] = [:]

    func resource(
        forIdentifier resourceIdentifier: String,
        loadOperation: sending @escaping () async throws -> R
    ) async throws -> R {
        if let phase = resources[resourceIdentifier] {
            return try await phase.resource
        }

        let task = ThrowingResourceTask {
            try await loadOperation()
        }

        resources[resourceIdentifier] = .inProgress(task)

        do {
            let resource = try await task.value
            resources[resourceIdentifier] = .success(resource)
            return resource
        } catch {
            resources[resourceIdentifier] = .failure(error)
            throw error
        }
    }
}
