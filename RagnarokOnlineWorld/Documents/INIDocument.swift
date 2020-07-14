//
//  INIDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/13.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

struct INIEntry {

    var name: String
    var value: String
}

struct INISection {

    var name: String
    var entries: [INIEntry]
}

struct INIDocument: Document {

    var sections: [INISection]

    init(from stream: Stream) throws {
        let reader = BinaryReader(stream: stream)

        var sections: [INISection] = []

        while let line = try? reader.readLine(separator: "\r\n") {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix(";") || line.hasPrefix("#") {
                continue
            } else if line.hasPrefix("[") && line.hasSuffix("]") {
                let startIndex = line.index(after: line.startIndex)
                let endIndex = line.index(before: line.endIndex)
                let sectionName = line[startIndex..<endIndex]
                let section = INISection(name: String(sectionName), entries: [])
                sections.append(section)
            } else {
                var components = line.split(separator: "=")
                if components.count != 2 {
                    components = line.split(separator: ":")
                }
                if components.count != 2 {
                    continue
                }
                let name = components[0]
                var value = components[1]

                if let index = value.firstIndex(of: ";") {
                    value = value.prefix(upTo: index)
                } else if let index = value.firstIndex(of: "#") {
                    value = value.prefix(upTo: index)
                }

                var section = sections.last ?? INISection(name: "", entries: [])
                let entry = INIEntry(name: String(name), value: String(value.trimmingCharacters(in: .whitespaces)))
                section.entries.append(entry)

                if !sections.isEmpty {
                    sections.removeLast()
                }
                sections.append(section)
            }
        }

        self.sections = sections
    }
}
