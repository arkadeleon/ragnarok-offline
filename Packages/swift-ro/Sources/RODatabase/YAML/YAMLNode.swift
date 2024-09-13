//
//  YAMLNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/18.
//

import ryml

enum YAMLNode {
    case null
    case scalar(String)
    case sequence([YAMLNode])
    case mapping([String : YAMLNode])

    init(from node: c4.yml.NodeRef) {
        if node.is_map() {
            var nodes: [String : YAMLNode] = [:]
            for pos in 0..<node.num_children() {
                let child = node.child(pos)
                nodes[child.key().string] = YAMLNode(from: child)
            }
            self = .mapping(nodes)
        } else if node.is_seq() {
            var nodes: [YAMLNode] = []
            for pos in 0..<node.num_children() {
                let child = node.child(pos)
                nodes.append(YAMLNode(from: child))
            }
            self = .sequence(nodes)
        } else if node.is_keyval() && !node.val_is_null() {
            self = .scalar(node.val().string)
        } else {
            self = .null
        }
    }

    func value() -> String? {
        if case .scalar(let value) = self {
            return value
        } else {
            return nil
        }
    }
}
