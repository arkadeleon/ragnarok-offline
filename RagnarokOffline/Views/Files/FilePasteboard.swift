//
//  FilePasteboard.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

class FilePasteboard {
    static let shared = FilePasteboard()

    var file: File?
    var hasFile = false

    func copy(_ file: File) {
        self.file = file
        hasFile = true
    }
}

extension File {
    func pasteFromPasteboard(_ pasteboard: FilePasteboard) -> File? {
        guard let sourceFile = pasteboard.file else {
            return nil
        }

        guard case .directory(let url) = self else {
            return nil
        }

        let destinationFile: File = .regularFile(url.appending(path: sourceFile.name))
        switch sourceFile {
        case.directory:
            return nil
        case .regularFile:
            do {
                try FileManager.default.copyItem(at: sourceFile.url, to: destinationFile.url)
                return destinationFile
            } catch {
                return nil
            }
        case .grf:
            return nil
        case .grfDirectory:
            return nil
        case .grfEntry(let grf, let entry):
            guard let contents = try? grf.contentsOfEntry(entry) else {
                return nil
            }
            do {
                try contents.write(to: destinationFile.url)
                return destinationFile
            } catch {
                return nil
            }
        }
    }
}
