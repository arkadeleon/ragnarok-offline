//
//  File+References.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/28.
//

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
            guard case .grfEntry(let grf, _) = node,
                  let data = await contents(),
                  let gnd = try? GND(data: data) else {
                return []
            }

            let referenceFiles = gnd.textures.map { textureName in
                let path = GRFPath(components: ["data", "texture", textureName])
                let file = FileNode.grfEntry(grf, path)
                return File(node: file)
            }
            return referenceFiles
        case .rsw:
            guard case .grfEntry(let grf, _) = node,
                  let data = await contents(),
                  let rsw = try? RSW(data: data) else {
                return []
            }

            var referenceFiles: [File] = []
            for model in rsw.models {
                let path = GRFPath(components: ["data", "model", model.modelName])
                let file = File(node: .grfEntry(grf, path))
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
