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

    case entry(URL, GRFDocument, String)

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .entry(_, _, let entryName):
            let lastPathComponent = entryName.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    var fileType: String {
        switch self {
        case .url(let url):
            return url.pathExtension
        case .entry(_, _, let entryName):
            let pathExtension = entryName.split(separator: "\\").last?.split(separator: ".").last
            return String(pathExtension ?? "")
        }
    }

    func data() throws -> Data {
        switch self {
        case .url(let url):
            return try Data(contentsOf: url)
        case .entry(let url, let grf, let entryName):
            guard let entry = grf.entry(forName: entryName) else {
                throw DocumentError.invalidSource
            }
            let stream = try FileStream(url: url)
            return try grf.contents(of: entry, from: stream)
        }
    }
}
