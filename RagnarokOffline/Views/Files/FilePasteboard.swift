//
//  FilePasteboard.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

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

        guard case .url(let url) = self else {
            return nil
        }

        let destinationFile = File.url(url.appending(path: sourceFile.name))
        switch sourceFile {
        case .url:
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