//
//  ASTNode.swift
//  RagnarokOfflineGenerator
//
//  Created by Leon Li on 2024/9/29.
//

struct ASTNode: Decodable {
    struct NodeType: Decodable {
        var desugaredQualType: String?
        var qualType: String?
    }

    struct NodeValue: Decodable {
        var intValue: Int?

        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int.self) {
                self.intValue = intValue
            } else if let stringValue = try? container.decode(String.self) {
                self.intValue = Int(stringValue)
            }
        }
    }

    struct ReferencedDecl: Decodable {
        var id: String?
        var kind: String?
        var name: String?
    }

    var id: String?
    var kind: String?
    var isReferenced: Bool?
    var name: String?
    var type: ASTNode.NodeType?
    var argType: ASTNode.NodeType?
    var value: ASTNode.NodeValue?
    var referencedDecl: ASTNode.ReferencedDecl?
    var opcode: String?
    var inner: [ASTNode]?

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

    func findFunctionDecl(named name: String) -> ASTNode? {
        findNode { node in
            node.kind == "FunctionDecl" && node.name == name
        }
    }

    func findCallExprs(fn: String) -> [ASTNode] {
        findNodes { node in
            guard node.kind == "CallExpr" else { return false }
            guard let first = node.inner?.first else { return false }

            let declRefExpr = first.findNode { node in
                node.kind == "DeclRefExpr" && node.referencedDecl?.name == fn
            }
            return declRefExpr != nil
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
