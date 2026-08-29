//
//  ResourceManager+Script.swift
//  RagnarokScript
//
//  Created by Leon Li on 2026/8/30.
//

import Foundation
import RagnarokResources

extension ResourceManager {
    func script(at path: ResourcePath) async -> Data? {
        do {
            let path = ResourcePath.scriptDirectory.appending(path: path).appendingPathExtension("lub")
            let data = try await contentsOfResource(at: path)
            return data
        } catch {
            logger.warning("\(error)")
            return nil
        }
    }
}
