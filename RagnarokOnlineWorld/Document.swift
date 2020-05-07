//
//  Document.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

protocol Document {

    var isDirectory: Bool { get }

    var icon: UIImage? { get }

    var name: String { get }

    var childDocuments: [Document]? { get }
}

extension URL: Document {

    var isDirectory: Bool {
        hasDirectoryPath
    }

    var icon: UIImage? {
        if isDirectory {
            return UIImage(systemName: "folder")
        } else {
            return UIImage(systemName: "doc")
        }
    }

    var name: String {
        if isDirectory {
            return lastPathComponent
        } else {
            return lastPathComponent
        }
    }

    var childDocuments: [Document]? {
        guard isDirectory else {
            return nil
        }

        let childDocuments = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
        return childDocuments
    }
}
