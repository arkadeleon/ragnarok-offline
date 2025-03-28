//
//  ModelResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import ROFileFormats
import ROResources

final public class ModelResource: Sendable {
    public let rsm: RSM

    public init(rsm: RSM) {
        self.rsm = rsm
    }
}

extension ResourceManager {
    public func model(at path: ResourcePath) async throws -> ModelResource {
        let data = try await contentsOfResource(at: path)
        let rsm = try RSM(data: data)

        let model = ModelResource(rsm: rsm)
        return model
    }
}
