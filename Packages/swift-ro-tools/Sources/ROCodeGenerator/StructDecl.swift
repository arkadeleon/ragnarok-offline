//
//  StructDecl.swift
//  ROTools
//
//  Created by Leon Li on 2024/11/21.
//

struct StructDecl {
    var name: String
    var fields: [FieldDecl]
    var nestedStructs: [StructDecl]

    init(name: String, fields: [FieldDecl]) {
        self.name = name
        self.fields = fields
        self.nestedStructs = []
    }

    init(node: ASTNode) {
        name = node.name ?? ""

        fields = node.inner!
            .filter {
                $0.kind == "FieldDecl"
            }
            .map {
                let fieldName = $0.name!
                let fieldType = FieldType(nodeType: $0.type!)!
                return FieldDecl(name: fieldName, type: fieldType)
            }

        nestedStructs = node.inner!
            .filter {
                $0.kind == "CXXRecordDecl" && $0.inner != nil
            }
            .map {
                StructDecl(node: $0)
            }
    }
}

struct FieldDecl {
    var name: String
    var type: FieldType
}

enum FieldType {
    case structure(StructureType)
    case array(StructureType)
    case fixedSizeArray(StructureType, Int)
    case string
    case fixedLengthString(Int)

    var annotation: String {
        switch self {
        case .structure(let structure):
            structure.name
        case .array(let structure):
            "[" + structure.name + "]"
        case .fixedSizeArray(let structure, _):
            "[" + structure.name + "]"
        case .string, .fixedLengthString:
            "String"
        }
    }

    var initialValue: String {
        switch self {
        case .structure(let structure):
            structure.initialValue
        case .array:
            "[]"
        case .fixedSizeArray:
            "[]"
        case .string, .fixedLengthString:
            "\"\""
        }
    }

    var structRef: StructureType? {
        switch self {
        case .structure(let structure):
            structure
        case .array(let structure):
            structure
        case .fixedSizeArray(let structure, _):
            structure
        case .string, .fixedLengthString:
            nil
        }
    }

    init?(nodeType: ASTNode.NodeType) {
        guard let qualType = nodeType.qualType else {
            return nil
        }

        switch qualType {
        case let qualType where qualType.hasSuffix("[]"):
            let structure = StructureType(name: qualType.replacingOccurrences(of: "[]", with: ""))
            if case .char = structure {
                self = .string
            } else {
                self = .array(structure)
            }
        case let qualType where qualType.contains("[") && qualType.contains("]"):
            let start = qualType.firstIndex(of: "[")!
            let end = qualType.firstIndex(of: "]")!
            let structure = StructureType(name: String(qualType[..<start]))
            let size = Int(qualType[(qualType.index(after: start))..<end])!
            if case .char = structure {
                self = .fixedLengthString(size)
            } else {
                self = .fixedSizeArray(structure, size)
            }
        default:
            let structure = StructureType(name: qualType)
            self = .structure(structure)
        }
    }
}

enum StructureType {
    case char
    case int8
    case uint8
    case int16
    case uint16
    case int32
    case uint32
    case int64
    case uint64
    case float
    case double
    case custom(String)

    var name: String {
        switch self {
        case .char:
            "Int8"
        case .int8:
            "Int8"
        case .uint8:
            "UInt8"
        case .int16:
            "Int16"
        case .uint16:
            "UInt16"
        case .int32:
            "Int32"
        case .uint32:
            "UInt32"
        case .int64:
            "Int64"
        case .uint64:
            "UInt64"
        case .float:
            "Float32"
        case .double:
            "Float64"
        case .custom(let name):
            name
        }
    }

    var initialValue: String {
        switch self {
        case .char:
            "0"
        case .int8:
            "0"
        case .uint8:
            "0"
        case .int16:
            "0"
        case .uint16:
            "0"
        case .int32:
            "0"
        case .uint32:
            "0"
        case .int64:
            "0"
        case .uint64:
            "0"
        case .float:
            "0"
        case .double:
            "0"
        case .custom(let name):
            "\(name)()"
        }
    }

    init(name: String) {
        self = switch name {
        case "char":
            .char
        case "bool", "int8":
            .int8
        case "uint8":
            .uint8
        case "int16":
            .int16
        case "uint16":
            .uint16
        case "int", "int32":
            .int32
        case "uint", "uint32":
            .uint32
        case "int64":
            .int64
        case "uint64":
            .uint64
        case "float":
            .float
        case "double":
            .double
        default:
            .custom(name.replacingOccurrences(of: "struct ", with: ""))
        }
    }
}
