//
//  ObservableFile.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import CoreTransferable
import Foundation
import Observation
import ROFileSystem

@Observable class ObservableFile {
    let file: File

    var thumbnail: FileThumbnail?

    init(file: File) {
        self.file = file
    }

    func fetchThumbnail(size: CGSize, scale: CGFloat) async throws {
        if thumbnail == nil {
            let request = FileThumbnailRequest(file: file, size: size, scale: scale)
            thumbnail = try await FileSystem.shared.thumbnail(for: request)
        }
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

extension ObservableFile: Equatable {
    static func == (lhs: ObservableFile, rhs: ObservableFile) -> Bool {
        lhs.file == rhs.file
    }
}

extension ObservableFile: Comparable {
    static func < (lhs: ObservableFile, rhs: ObservableFile) -> Bool {
        lhs.file < rhs.file
    }
}

extension ObservableFile: Identifiable {
    var id: URL {
        file.url
    }
}

extension ObservableFile: Hashable {
    func hash(into hasher: inout Hasher) {
        file.hash(into: &hasher)
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
