//
//  NativeType.swift
//  ROTools
//
//  Created by Leon Li on 2024/11/21.
//

enum NativeType {
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

    var size: String {
        switch self {
        case .structure(let structure):
            structure.size
        case .array(let structure):
            "0"
        case .fixedSizeArray(let structure, let size):
            "\(structure.size) * \(size)"
        case .string:
            "0"
        case .fixedLengthString(let lengthOfBytes):
            "\(lengthOfBytes)"
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

extension NativeType {
    enum StructureType {
        case char
        case number(NumberType)
        case custom(String)

        var name: String {
            switch self {
            case .char:
                "Int8"
            case .number(let number):
                number.name
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

        var size: String {
            switch self {
            case .char:
                "1"
            case .number(let number):
                number.size
            case .custom(let name):
                "MemoryLayout<\(name)>.size"
            }
        }

        init(name: String) {
            self = switch name {
            case "char":
                .char
            case "bool", "int8":
                .number(.int8)
            case "uint8":
                .number(.uint8)
            case "int16":
                .number(.int16)
            case "uint16":
                .number(.uint16)
            case "int", "int32":
                .number(.int32)
            case "uint", "uint32":
                .number(.uint32)
            case "int64":
                .number(.int64)
            case "uint64":
                .number(.uint64)
            case "float":
                .number(.float)
            case "double":
                .number(.double)
            default:
                .custom(name.replacingOccurrences(of: "struct ", with: ""))
            }
        }
    }
}

extension NativeType.StructureType {
    enum NumberType {
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

        var name: String {
            switch self {
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
            }
        }

        var size: String {
            switch self {
            case .int8:
                "1"
            case .uint8:
                "1"
            case .int16:
                "2"
            case .uint16:
                "2"
            case .int32:
                "4"
            case .uint32:
                "4"
            case .int64:
                "8"
            case .uint64:
                "8"
            case .float:
                "4"
            case .double:
                "8"
            }
        }
    }
}
