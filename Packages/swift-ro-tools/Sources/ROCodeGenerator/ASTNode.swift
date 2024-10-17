//
//  ASTNode.swift
//  ROCodeGenerator
//
//  Created by Leon Li on 2024/9/29.
//

struct ASTNode: Decodable {
    struct NodeType: Decodable {
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
    var value: ASTNode.NodeValue?
    var referencedDecl: ASTNode.ReferencedDecl?
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

extension ASTNode.NodeType {
    var asSwiftType: String? {
        guard let qualType else {
            return nil
        }

        let swiftType: String? = switch qualType {
        case "int8": "Int8"
        case "uint8": "UInt8"
        case "int16": "Int16"
        case "uint16": "UInt16"
        case "int32": "Int32"
        case "uint32": "UInt32"
        case "char[]": "[UInt8]"
        default: nil
        }

        return swiftType ?? qualType
    }
}
