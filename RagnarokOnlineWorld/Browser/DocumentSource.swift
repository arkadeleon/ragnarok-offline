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

    case entry(URL, String)

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .entry(_, let name):
            let lastPathComponent = name.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    var fileType: String {
        switch self {
        case .url(let url):
            return url.pathExtension
        case .entry(_, let name):
            let pathExtension = name.split(separator: "\\").last?.split(separator: ".").last
            return String(pathExtension ?? "")
        }
    }

    func data() throws -> Data {
        switch self {
        case .url(let url):
            return try Data(contentsOf: url)
        case .entry(let url, let name):
            guard let grf = ResourceManager.default.grf(for: url),
                  let entry = grf.entry(forName: name)
            else {
                throw DocumentError.invalidSource
            }
            let stream = try FileStream(url: url)
            return try grf.contents(of: entry, from: stream)
        }
    }
}
