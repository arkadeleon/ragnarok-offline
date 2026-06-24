//
//  ResourceProvider.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/6/24.
//

import Foundation

public protocol ResourceProvider: Sendable {
    func contentsOfResource(at path: ResourcePath) async throws -> Data
}
