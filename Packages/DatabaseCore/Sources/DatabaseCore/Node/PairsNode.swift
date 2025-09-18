//
//  PairsNode.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/1/10.
//

struct PairsNode<Key, Value>: Sequence, Decodable where Key: CaseIterable, Key: CodingKey, Value: Decodable {
    private var children: [(Key, Value)]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.children = try Key.allCases.compactMap { key in
            if let value = try container.decodeIfPresent(Value.self, forKey: key) {
                return (key, value)
            } else {
                return nil
            }
        }
    }

    func makeIterator() -> [(Key, Value)].Iterator {
        children.makeIterator()
    }
}

extension PairsNode where Key: Hashable {
    var dictionary: [Key : Value] {
        Dictionary(uniqueKeysWithValues: children)
    }
}

extension PairsNode where Value == Bool {
    var keys: [Key] {
        let allCasesButAll = Key.allCases.filter { $0.stringValue != "All" }

        var keys = children.contains(where: { $0.0.stringValue == "All" }) ? allCasesButAll : []

        for child in children where child.0.stringValue != "All" {
            if child.1 {
                keys.append(child.0)
            } else {
                keys.removeAll(where: { $0.stringValue == child.0.stringValue })
            }
        }

        return keys
    }
}
