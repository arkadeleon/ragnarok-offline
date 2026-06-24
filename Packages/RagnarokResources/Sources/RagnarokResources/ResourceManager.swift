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
    public let localClient: LocalResourceClient
    public let remoteClient: RemoteResourceClient?

    private let scriptContextLoader = ScriptContextLoader()
    public var scriptContext: ScriptContext {
        get async {
            await scriptContextLoader.scriptContext(using: self)
        }
    }

    let cache = ResourceCache()
    let imageResourceCache = ThrowingResourceCache<Resources.Image>()

    public init(localClient: LocalResourceClient, remoteClient: RemoteResourceClient? = nil) {
        self.localClient = localClient
        self.remoteClient = remoteClient
    }

    public func setRemoteClientEnabled(_ isEnabled: Bool) async {
        await remoteClient?.setEnabled(isEnabled)
        await clearCaches()
    }

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        do {
            return try await localClient.contentsOfResource(at: path)
        } catch ResourceError.resourceNotFound {
            if let remoteClient {
                return try await remoteClient.contentsOfResource(at: path)
            }
        }

        throw ResourceError.resourceNotFound(path)
    }

    private func clearCaches() async {
        await scriptContextLoader.clear()
        await cache.clear()
        await imageResourceCache.clear()
    }
}
