//
//  ScriptResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/3.
//

import Foundation

final public class ScriptResource: Sendable {
    public let data: Data

    public init(data: Data) {
        self.data = data
    }
}
