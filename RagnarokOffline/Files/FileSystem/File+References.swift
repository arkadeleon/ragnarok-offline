//
//  File+References.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/28.
//

import Foundation
import GRF
import RagnarokFileFormats
import RagnarokResources
import TextEncoding

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
            await gndReferenceFiles()
        case .rsw:
            await rswReferenceFiles()
        default:
            []
        }
    }

    func gndReferenceFiles() async -> [File] {
        guard let data = try? await contents(),
              let gnd = try? GND(data: data) else {
            return []
        }

        switch node {
        case .regularFile(let url):
            var referenceFiles: [File] = []
            for textureName in gnd.textures {
                let components = textureName.split(separator: "\\").map(String.init).map(L2K)
                let texturePath = ResourcePath.textureDirectory.appending(components)
                let textureURL = url.deletingLastPathComponent().deletingLastPathComponent().appending(path: texturePath)
                guard FileManager.default.fileExists(atPath: textureURL.path(percentEncoded: false)) else {
                    continue
                }
                let file = File(node: .regularFile(textureURL), location: location)
                referenceFiles.append(file)
            }
            return referenceFiles
        case .grfArchiveNode(let grfArchive, _):
            var referenceFiles: [File] = []
            for textureName in gnd.textures {
                let path = GRFPath(components: ["data", "texture", textureName])
                guard let node = await grfArchive.entryNode(at: path) else {
                    continue
                }
                let file = File(node: .grfArchiveNode(grfArchive, node), location: location)
                referenceFiles.append(file)
            }
            return referenceFiles
        default:
            return []
        }
    }

    func rswReferenceFiles() async -> [File] {
        guard let data = try? await contents(),
              let rsw = try? RSW(data: data) else {
            return []
        }

        switch node {
        case .regularFile(let url):
            var referenceFiles: [File] = []
            for model in rsw.models {
                let components = model.modelName.split(separator: "\\").map(String.init).map(L2K)
                let modelPath = ResourcePath.modelDirectory.appending(components)
                let modelURL = url.deletingLastPathComponent().deletingLastPathComponent().appending(path: modelPath)
                guard FileManager.default.fileExists(atPath: modelURL.path(percentEncoded: false)) else {
                    continue
                }
                let file = File(node: .regularFile(modelURL), location: location)
                if !referenceFiles.contains(file) {
                    referenceFiles.append(file)
                }
            }
            return referenceFiles
        case .grfArchiveNode(let grfArchive, _):
            var referenceFiles: [File] = []
            for model in rsw.models {
                let path = GRFPath(components: ["data", "model", model.modelName])
                guard let node = await grfArchive.entryNode(at: path) else {
                    continue
                }
                let file = File(node: .grfArchiveNode(grfArchive, node), location: location)
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
