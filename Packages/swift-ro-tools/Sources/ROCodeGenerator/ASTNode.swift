//
//  ASTNode.swift
//  ROTools
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
    enum SwiftType {
        case structure(StructureType)
        case structureArray(StructureType)
        case fixedSizeStructureArray(StructureType, Int)

        var attributes: [String] {
            switch self {
            case .fixedSizeStructureArray(_, let size):
                ["@FixedSizeArray(size: \(size), initialValue: .init())\n"]
            default:
                []
            }
        }

        var annotation: String {
            switch self {
            case .structure(let structure):
                structure.name
            case .structureArray(let structure):
                "[" + structure.name + "]"
            case .fixedSizeStructureArray(let structure, _):
                "[" + structure.name + "]"
            }
        }
    }

    enum StructureType {
        case standard(String)
        case custom(String)

        var name: String {
            switch self {
            case .standard(let name):
                name
            case .custom(let name):
                name
            }
        }

        init(name: String) {
            self = switch name {
            case "bool", "char", "int8":
                .standard("Int8")
            case "uint8":
                .standard("UInt8")
            case "int16":
                .standard("Int16")
            case "uint16":
                .standard("UInt16")
            case "int", "int32":
                .standard("Int32")
            case "uint", "uint32":
                .standard("UInt32")
            case "int64":
                .standard("Int64")
            case "uint64":
                .standard("UInt64")
            case "float":
                .standard("Float32")
            case "double":
                .standard("Float64")
            default:
                .custom(name.replacingOccurrences(of: "struct ", with: ""))
            }
        }
    }

    var isFixedSizeArray: Bool {
        guard let swiftType = asSwiftType else {
            return false
        }
        if case .fixedSizeStructureArray = swiftType {
            return true
        } else {
            return false
        }
    }

    var asSwiftType: SwiftType? {
        guard let qualType else {
            return nil
        }

        switch qualType {
        case let qualType where qualType.hasSuffix("[]"):
            let structure = StructureType(name: qualType.replacingOccurrences(of: "[]", with: ""))
            return .structureArray(structure)
        case let qualType where qualType.contains("[") && qualType.contains("]"):
            let start = qualType.firstIndex(of: "[")!
            let end = qualType.firstIndex(of: "]")!
            let structure = StructureType(name: String(qualType[..<start]))
            let size = Int(qualType[(qualType.index(after: start))..<end])!
            return .fixedSizeStructureArray(structure, size)
        default:
            let structure = StructureType(name: qualType)
            return .structure(structure)
        }
    }

}
