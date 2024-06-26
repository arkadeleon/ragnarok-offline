//
//  YAMLParser.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/19.
//

import ryml

class YAMLParser {
    let yaml: String
    private var parser: c4.yml.Parser

    init(yaml: String) {
        self.yaml = yaml
        self.parser = c4.yml.Parser()
    }

    func parse() -> YAMLNode {
        let tree = parser.parse_in_arena(c4.to_csubstr(""), yaml.csubstr)
        let node = YAMLNode(from: tree.rootref())
        return node
    }
}
