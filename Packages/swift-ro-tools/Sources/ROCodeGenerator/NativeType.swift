//
//  NativeType.swift
//  ROTools
//
//  Created by Leon Li on 2024/11/21.
//

enum NativeType {
    case structure(StructureType)
    case structureArray(StructureType)
    case fixedSizeStructureArray(StructureType, Int)
    case string
    case fixedLengthString(Int)

    var annotation: String {
        switch self {
        case .structure(let structure):
            structure.name
        case .structureArray(let structure):
            "[" + structure.name + "]"
        case .fixedSizeStructureArray(let structure, _):
            "[" + structure.name + "]"
        case .string, .fixedLengthString:
            "String"
        }
    }

    var initialValue: String {
        switch self {
        case .structure(let structure):
            structure.initialValue
        case .structureArray:
            "[]"
        case .fixedSizeStructureArray:
            "[]"
        case .string, .fixedLengthString:
            "\"\""
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
                self = .structureArray(structure)
            }
        case let qualType where qualType.contains("[") && qualType.contains("]"):
            let start = qualType.firstIndex(of: "[")!
            let end = qualType.firstIndex(of: "]")!
            let structure = StructureType(name: String(qualType[..<start]))
            let size = Int(qualType[(qualType.index(after: start))..<end])!
            if case .char = structure {
                self = .fixedLengthString(size)
            } else {
                self = .fixedSizeStructureArray(structure, size)
            }
        default:
            let structure = StructureType(name: qualType)
            self = .structure(structure)
        }
    }
}

extension NativeType {
    enum StructureType {
        case char
        case number(String)
        case custom(String)

        var name: String {
            switch self {
            case .char:
                "Int8"
            case .number(let name):
                name
            case .custom(let name):
                name
            }
        }

        var initialValue: String {
            switch self {
            case .char:
                "0"
            case .number:
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
                    .number("Int8")
            case "uint8":
                    .number("UInt8")
            case "int16":
                    .number("Int16")
            case "uint16":
                    .number("UInt16")
            case "int", "int32":
                    .number("Int32")
            case "uint", "uint32":
                    .number("UInt32")
            case "int64":
                    .number("Int64")
            case "uint64":
                    .number("UInt64")
            case "float":
                    .number("Float32")
            case "double":
                    .number("Float64")
            default:
                    .custom(name.replacingOccurrences(of: "struct ", with: ""))
            }
        }
    }
}
