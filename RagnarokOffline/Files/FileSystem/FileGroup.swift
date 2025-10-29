//
//  FileGroup.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/29.
//

struct FileGroup: Hashable {
    enum GroupType {
        case references
    }

    var file: File
    var type: FileGroup.GroupType

    var name: String {
        switch type {
        case .references:
            "\(file.name) - References"
        }
    }

    func files() async -> [File] {
        switch type {
        case .references:
            await file.referenceFiles()
        }
    }
}
