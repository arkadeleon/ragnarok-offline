//
//  DocumentSource.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum DocumentSource {

    case url(URL)

    case entryInArchive(URL, GRFDocument, String)

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .entryInArchive(_, _, let entryName):
            let lastPathComponent = entryName.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    var fileType: String {
        switch self {
        case .url(let url):
            return url.pathExtension
        case .entryInArchive(_, _, let entryName):
            let pathExtension = entryName.split(separator: "\\").last?.split(separator: ".").last
            return String(pathExtension ?? "")
        }
    }

    func data() throws -> Data {
        switch self {
        case .url(let url):
            return try Data(contentsOf: url)
        case .entryInArchive(let url, let archive, let entryName):
            guard let entry = archive.entry(forName: entryName) else {
                return Data()
            }
            let stream = try FileStream(url: url)
            return try archive.contents(of: entry, from: stream)
        }
    }
}
