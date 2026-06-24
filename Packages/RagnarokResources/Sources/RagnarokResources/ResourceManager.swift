//
//  ResourceManager.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/2/14.
//

import Foundation

public enum ResourceError: LocalizedError {
    case resourceNotFound(ResourcePath)
    case scriptContextIncomplete(String)

    public var errorDescription: String? {
        switch self {
        case .resourceNotFound(let path):
            String(localized: "Resource not found at \(path.components.joined(separator: "/"))")
        case .scriptContextIncomplete(let call):
            String(localized: "Script context incomplete: \(call)")
        }
    }
}

final public class ResourceManager: Sendable {
    let resourceProvider: any ResourceProvider

    private let scriptContextLoader = ScriptContextLoader()
    public var scriptContext: ScriptContext {
        get async {
            await scriptContextLoader.scriptContext(using: self)
        }
    }

    let cache = ResourceCache()
    let imageResourceCache = ThrowingResourceCache<Resources.Image>()

    public init(resourceProvider: any ResourceProvider) {
        self.resourceProvider = resourceProvider
    }

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        try await resourceProvider.contentsOfResource(at: path)
    }

    public func clearCaches() async {
        await scriptContextLoader.clear()
        await cache.clear()
        await imageResourceCache.clear()
    }
}
