//
//  RSMModelResource.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2025/2/26.
//

import RagnarokFileFormats
import RagnarokResources

final public class RSMModelResource: Sendable {
    public let rsm: RSM
    public let textureNames: Set<String>

    public init(rsm: RSM) {
        self.rsm = rsm
        self.textureNames = Set(rsm.nodes.flatMap(\.textures))
    }
}

extension ResourceManager {
    public func models(forNames modelNames: some Collection<String>) async -> [String : RSMModelResource] {
        await withTaskGroup(
            of: (String, RSMModelResource?).self,
            returning: [String : RSMModelResource].self
        ) { taskGroup in
            for modelName in modelNames {
                taskGroup.addTask {
                    let modelResource = try? await self.model(forName: modelName)
                    if let modelResource {
                        return (modelName, modelResource)
                    } else {
                        return (modelName, nil)
                    }
                }
            }

            var modelResources: [String : RSMModelResource] = [:]
            for await (modelName, modelResource) in taskGroup {
                modelResources[modelName] = modelResource
            }
            return modelResources
        }
    }

    public func model(forName modelName: String) async throws -> RSMModelResource {
        let components = modelName.split(separator: "\\").map(String.init)
        let modelPath = ResourcePath.modelDirectory.appending(components)
        let modelResource = try await model(at: modelPath)
        return modelResource
    }

    public func model(at path: ResourcePath) async throws -> RSMModelResource {
        let data = try await contentsOfResource(at: path)
        let rsm = try RSM(data: data)
        let modelResource = RSMModelResource(rsm: rsm)
        return modelResource
    }
}
