//
//  YAMLNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/18.
//

import ryml

enum YAMLNode {
    case map([String : YAMLNode])
    case sequence([YAMLNode])
    case value(String)
    case null

    init(from node: c4.yml.NodeRef) {
        if node.is_map() {
            var nodes: [String : YAMLNode] = [:]
            for pos in 0..<node.num_children() {
                let child = node.child(pos)
                nodes[child.key().string] = YAMLNode(from: child)
            }
            self = .map(nodes)
        } else if node.is_seq() {
            var nodes: [YAMLNode] = []
            for pos in 0..<node.num_children() {
                let child = node.child(pos)
                nodes.append(YAMLNode(from: child))
            }
            self = .sequence(nodes)
        } else if node.is_keyval() && !node.val_is_null() {
            self = .value(node.val().string)
        } else {
            self = .null
        }
    }

    func value() -> String? {
        if case .value(let string) = self {
            return string
        } else {
            return nil
        }
    }
}
