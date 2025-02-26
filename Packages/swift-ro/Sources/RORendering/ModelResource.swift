//
//  ModelResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import ROFileFormats

final public class ModelResource: Sendable {
    public let rsm: RSM

    public init(rsm: RSM) {
        self.rsm = rsm
    }
}
