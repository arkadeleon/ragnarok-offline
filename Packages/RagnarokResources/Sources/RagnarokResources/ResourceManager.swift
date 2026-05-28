//
//  ResourceManager.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/2/14.
//

import Foundation
import RagnarokGRF

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

public enum ResourceLocator: Sendable {
    case url(URL)
    case grfArchiveNode(GRFArchive, GRFNode)
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

    public func locatorOfResource(at path: ResourcePath) async throws -> ResourceLocator {
        try await localClient.locatorOfResource(at: path)
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
