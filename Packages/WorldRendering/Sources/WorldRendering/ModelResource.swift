//
//  ModelResource.swift
//  WorldRendering
//
//  Created by Leon Li on 2025/2/26.
//

import FileFormats
import ResourceManagement

final public class ModelResource: Sendable {
    public let rsm: RSM

    public init(rsm: RSM) {
        self.rsm = rsm
    }
}

extension ResourceManager {
    public func models(forNames modelNames: some Collection<String>) async -> [String : ModelResource] {
        await withTaskGroup(
            of: (String, ModelResource?).self,
            returning: [String : ModelResource].self
        ) { taskGroup in
            for modelName in modelNames {
                taskGroup.addTask {
                    let model = try? await self.model(forName: modelName)
                    if let model {
                        return (modelName, model)
                    } else {
                        return (modelName, nil)
                    }
                }
            }

            var models: [String : ModelResource] = [:]
            for await (modelName, model) in taskGroup {
                models[modelName] = model
            }
            return models
        }
    }

    public func model(forName modelName: String) async throws -> ModelResource {
        let components = modelName.split(separator: "\\").map(String.init)
        let modelPath = ResourcePath.modelDirectory.appending(components)

        let model = try await model(at: modelPath)
        return model
    }

    public func model(at path: ResourcePath) async throws -> ModelResource {
        let data = try await contentsOfResource(at: path)
        let rsm = try RSM(data: data)

        let model = ModelResource(rsm: rsm)
        return model
    }
}
