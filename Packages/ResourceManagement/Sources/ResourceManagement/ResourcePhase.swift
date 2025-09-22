//
//  ResourcePhase.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/9/22.
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
