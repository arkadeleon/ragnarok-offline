//
//  File+References.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/28.
//

import FileFormats
import GRF

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
            guard case .grfArchiveNode(let grfArchive, _) = node,
                  let data = try? await contents(),
                  let gnd = try? GND(data: data) else {
                return []
            }

            var referenceFiles: [File] = []
            for textureName in gnd.textures {
                let path = GRFPath(components: ["data", "texture", textureName])
                guard let entryNode = await grfArchive.entryNode(at: path) else {
                    continue
                }
                let file = File(node: .grfArchiveNode(grfArchive, entryNode))
                referenceFiles.append(file)
            }
            return referenceFiles
        case .rsw:
            guard case .grfArchiveNode(let grfArchive, _) = node,
                  let data = try? await contents(),
                  let rsw = try? RSW(data: data) else {
                return []
            }

            var referenceFiles: [File] = []
            for model in rsw.models {
                let path = GRFPath(components: ["data", "model", model.modelName])
                guard let entryNode = await grfArchive.entryNode(at: path) else {
                    continue
                }
                let file = File(node: .grfArchiveNode(grfArchive, entryNode))
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
