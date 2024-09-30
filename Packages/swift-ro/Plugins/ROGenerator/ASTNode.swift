//
//  ASTNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/29.
//

struct ASTNode: Decodable {
    var id: String?
    var kind: String?
    var isReferenced: Bool?
    var name: String?
    var value: Int?
    var inner: [ASTNode]?

    enum CodingKeys: CodingKey {
        case id
        case kind
        case isReferenced
        case name
        case value
        case inner
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.kind = try container.decodeIfPresent(String.self, forKey: .kind)
        self.isReferenced = try container.decodeIfPresent(Bool.self, forKey: .isReferenced)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.value = if let intValue = try? container.decodeIfPresent(Int.self, forKey: .value) {
            intValue
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .value) {
            Int(stringValue)
        } else {
            nil
        }
        self.inner = try container.decodeIfPresent([ASTNode].self, forKey: .inner)
    }

    func findEnumDecl(named name: String) -> ASTNode? {
        findNode { node in
            node.kind == "EnumDecl" && node.name == name && node.inner != nil
        }
    }

    func findEnumConstantDecls() -> [ASTNode] {
        findNodes { node in
            node.kind == "EnumConstantDecl"
        }
    }

    func findConstantExpr() -> ASTNode? {
        findNode { node in
            node.kind == "ConstantExpr"
        }
    }

    func findNode(where predicate: (ASTNode) -> Bool) -> ASTNode? {
        if predicate(self) {
            return self
        }

        if let inner {
            for i in inner {
                if let n = i.findNode(where: predicate) {
                    return n
                }
            }
        }

        return nil
    }

    func findNodes(where predicate: (ASTNode) -> Bool) -> [ASTNode] {
        var nodes: [ASTNode] = []

        if predicate(self) {
            nodes.append(self)
        }

        if let inner {
            for i in inner {
                let ns = i.findNodes(where: predicate)
                nodes.append(contentsOf: ns)
            }
        }

        return nodes
    }
}
