//
//  ResourceCache.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/9/28.
//

typealias ResourceTask = Task<any Resource, Never>

/// The current phase of the resource loading operation.
enum ResourcePhase {
    case inProgress(ResourceTask)
    case loaded(any Resource)

    var resource: any Resource {
        get async {
            switch self {
            case .inProgress(let task):
                await task.value
            case .loaded(let resource):
                resource
            }
        }
    }
}

actor ResourceCache {
    private var resources: [String : ResourcePhase] = [:]

    func resource<R>(
        forIdentifier resourceIdentifier: String,
        loadOperation: sending @escaping () async -> R
    ) async -> R where R: Resource {
        if let phase = resources[resourceIdentifier] {
            return await phase.resource as! R
        }

        let task = ResourceTask {
            await loadOperation()
        }

        resources[resourceIdentifier] = .inProgress(task)

        let resource = await task.value

        resources[resourceIdentifier] = .loaded(resource)

        return resource as! R
    }
}
