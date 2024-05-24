//
//  File+Actions.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import CoreTransferable
import Foundation

extension File {
    public var canPreview: Bool {
        switch info.type {
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

    public var canShare: Bool {
        switch self {
        case .directory, .grfDirectory: false
        default: true
        }
    }

    public var canCopy: Bool {
        switch self {
        case .regularFile, .grf, .grfEntry: true
        default: false
        }
    }

    public var canPaste: Bool {
        switch self {
        case .directory where FilePasteboard.shared.hasFile: true
        default: false
        }
    }

    public var canDelete: Bool {
        switch self {
        case .regularFile, .grf: true
        default: false
        }
    }

    public func copy(_ file: File) {
        FilePasteboard.shared.copy(file)
    }

    public func delete(_ file: File) -> Bool {
        guard case .regularFile(let url) = file else {
            return false
        }

        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}

extension File: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { file in
            file.shareURL ?? file.url
        }
    }

    private var shareURL: URL? {
        switch self {
        case .directory, .grfDirectory:
            return nil
        case .regularFile, .grf:
            return url
        case .grfEntry:
            guard let data = contents() else {
                return nil
            }
            do {
                let temporaryURL = FileManager.default.temporaryDirectory.appending(path: name)
                try data.write(to: temporaryURL)
                return temporaryURL
            } catch {
                return nil
            }
        }
    }
}
