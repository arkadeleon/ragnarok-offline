//
//  ObservableFile.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

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
