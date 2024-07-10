//
//  ObservableFile.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import CoreTransferable
import Foundation
import Observation
import ROFileFormats
import ROFileSystem

@Observable 
class ObservableFile {
    let file: File

    init(file: File) {
        self.file = file
    }

    func fetchThumbnail(size: CGSize, scale: CGFloat) async throws -> FileThumbnail? {
        let request = FileThumbnailRequest(file: file, size: size, scale: scale)
        let thumbnail = try await FileSystem.shared.thumbnail(for: request)
        return thumbnail
    }
}

extension ObservableFile {
    var iconName: String {
        switch file.info.type {
        case .directory:
            "folder.fill"
        case .text, .lua, .lub:
            "doc.text"
        case .image, .ebm, .pal:
            "photo"
        case .audio:
            "waveform.circle"
        case .grf:
            "doc.zipper"
        case .act:
            "livephoto"
        case .gat:
            "square.grid.3x3.middle.filled"
        case .gnd:
            "mountain.2"
        case .rsm:
            "square.stack.3d.up"
        case .rsw:
            "map"
        case .spr:
            "photo.stack"
        case .str:
            "sparkles.rectangle.stack"
        case .unknown:
            "doc"
        }
    }
}

extension ObservableFile {
    var canPreview: Bool {
        switch file.info.type {
        case .text, .lua, .lub:
            true
        case .image, .ebm, .pal:
            true
        case .audio:
            true
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            true
        default:
            false
        }
    }

    var canShare: Bool {
        switch file {
        case .directory, .grfDirectory: 
            false
        default: 
            true
        }
    }

    var canCopy: Bool {
        switch file {
        case .regularFile, .grf, .grfEntry:
            true
        default:
            false
        }
    }

    var canPaste: Bool {
        switch file {
        case .directory where FilePasteboard.shared.hasFile:
            true
        default: 
            false
        }
    }

    var canDelete: Bool {
        switch file {
        case .regularFile, .grf:
            true
        default:
            false
        }
    }
}

extension ObservableFile {
    var rawDataRepresentable: Bool {
        switch file.info.type {
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            true
        default:
            false
        }
    }

    var rawData: Data? {
        guard rawDataRepresentable else {
            return nil
        }

        guard let data = file.contents() else {
            return nil
        }

        let value: Encodable? = switch file.info.type {
        case .act: try? ACT(data: data)
        case .gat: try? GAT(data: data)
        case .gnd: try? GND(data: data)
        case .rsm: try? RSM(data: data)
        case .rsw: try? RSW(data: data)
        case .spr: try? SPR(data: data)
        case .str: try? STR(data: data)
        default: nil
        }

        guard let value else {
            return nil
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        let rawData = try? encoder.encode(value)
        return rawData
    }
}

extension ObservableFile {
    var hasReferences: Bool {
        switch file.info.type {
        case .gnd, .rsw:
            true
        default:
            false
        }
    }

    func referenceFiles() throws -> [ObservableFile] {
        switch file.info.type {
        case .gnd:
            guard case .grfEntry(let grf, _) = file, let data = file.contents() else {
                return []
            }
            let gnd = try GND(data: data)
            let referenceFiles = gnd.textures.map { textureName in
                let path = GRF.Path(string: "data\\texture\\" + textureName)
                let file = File.grfEntry(grf, path)
                return ObservableFile(file: file)
            }
            return referenceFiles
        case .rsw:
            guard case .grfEntry(let grf, _) = file, let data = file.contents() else {
                return []
            }
            let rsw = try RSW(data: data)
            var referenceFiles: [ObservableFile] = []
            for model in rsw.models {
                let path = GRF.Path(string: "data\\model\\" + model.modelName)
                let file = ObservableFile(file: .grfEntry(grf, path))
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

extension ObservableFile: Equatable {
    static func == (lhs: ObservableFile, rhs: ObservableFile) -> Bool {
        lhs.file.url == rhs.file.url
    }
}

extension ObservableFile: Comparable {
    static func < (lhs: ObservableFile, rhs: ObservableFile) -> Bool {
        let lhsRank = switch lhs.file {
        case .directory, .grfDirectory: 0
        case .grf: 1
        default: 2
        }

        let rhsRank = switch rhs.file {
        case .directory, .grfDirectory: 0
        case .grf: 1
        default: 2
        }

        if lhsRank == rhsRank {
            return lhs.file.name.lowercased() < rhs.file.name.lowercased()
        } else {
            return lhsRank < rhsRank
        }
    }
}

extension ObservableFile: Identifiable {
    var id: URL {
        file.url
    }
}

extension ObservableFile: Hashable {
    func hash(into hasher: inout Hasher) {
        file.url.hash(into: &hasher)
    }
}

extension ObservableFile: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { file in
            file.shareURL ?? file.file.url
        }
    }

    var shareURL: URL? {
        switch file {
        case .directory, .grfDirectory:
            return nil
        case .regularFile, .grf:
            return file.url
        case .grfEntry:
            guard let data = file.contents() else {
                return nil
            }
            do {
                let temporaryURL = FileManager.default.temporaryDirectory.appending(path: file.name)
                try data.write(to: temporaryURL)
                return temporaryURL
            } catch {
                return nil
            }
        }
    }
}
