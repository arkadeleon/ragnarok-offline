//
//  INI.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/13.
//

import Foundation

struct INI {
    var sections: [Section] = []

    init(url: URL) throws {
        let contents = try String(contentsOf: url)
        let lines = contents.split(separator: "\r\n")

        for line in lines {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix(";") || line.hasPrefix("#") {
                continue
            } else if line.hasPrefix("[") && line.hasSuffix("]") {
                let startIndex = line.index(after: line.startIndex)
                let endIndex = line.index(before: line.endIndex)
                let sectionName = line[startIndex..<endIndex]
                let section = Section(name: String(sectionName), entries: [])
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

                var section = sections.last ?? Section(name: "", entries: [])
                let entry = Entry(name: String(name), value: String(value.trimmingCharacters(in: .whitespaces)))
                section.entries.append(entry)

                if !sections.isEmpty {
                    sections.removeLast()
                }
                sections.append(section)
            }
        }
    }
}

extension INI {
    struct Section {
        var name: String
        var entries: [Entry]
    }
}

extension INI {
    struct Entry {
        var name: String
        var value: String
    }
}
