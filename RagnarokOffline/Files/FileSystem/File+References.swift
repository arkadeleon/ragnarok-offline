//
//  File+References.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/28.
//

import GRF
import ROFileFormats

extension File {
    var hasReferences: Bool {
        switch utType {
        case .gnd, .rsw:
            true
        default:
            false
        }
    }

    func referenceFiles() async -> [File] {
        switch utType {
        case .gnd:
            guard case .grfArchiveEntry(let grfArchive, _) = node,
                  let data = await contents(),
                  let gnd = try? GND(data: data) else {
                return []
            }

            var referenceFiles: [File] = []
            for textureName in gnd.textures {
                let path = GRFPath(components: ["data", "texture", textureName])
                guard let entry = await grfArchive.entry(at: path) else {
                    continue
                }
                let file = File(node: .grfArchiveEntry(grfArchive, entry))
                referenceFiles.append(file)
            }
            return referenceFiles
        case .rsw:
            guard case .grfArchiveEntry(let grfArchive, _) = node,
                  let data = await contents(),
                  let rsw = try? RSW(data: data) else {
                return []
            }

            var referenceFiles: [File] = []
            for model in rsw.models {
                let path = GRFPath(components: ["data", "model", model.modelName])
                guard let entry = await grfArchive.entry(at: path) else {
                    continue
                }
                let file = File(node: .grfArchiveEntry(grfArchive, entry))
                if !referenceFiles.contains(file) {
                    referenceFiles.append(file)
                }
            }
            return referenceFiles
        default:
            return []
        }
    }
}
