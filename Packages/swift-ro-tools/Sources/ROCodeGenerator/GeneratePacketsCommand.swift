//
//  GeneratePacketsCommand.swift
//  ROTools
//
//  Created by Leon Li on 2024/10/18.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct GeneratePacketsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "generate-packets")

    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var rathenaDirectory: URL

    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory).appending(path: "Packets") })
    var generatedDirectory: URL

    mutating func run() throws {
        try? FileManager.default.removeItem(at: generatedDirectory)
        try? FileManager.default.createDirectory(at: generatedDirectory, withIntermediateDirectories: true)

        try generatePackets()
        try generatePacketStructures()
//        try generatePacketDatabase()
    }

    // MARK: - Generate Packet Database

    private func generatePackets() throws {
        let packetdbURL = rathenaDirectory.appending(path: "src/map/clif_packetdb.hpp")
        let shuffleURL = rathenaDirectory.appending(path: "src/map/clif_shuffle.hpp")

        let packetdbLines = try outputLines(for: packetdbURL)
            .map({ "    \($0)" })
            .joined(separator: "\n")
        let packetdbOutputContents = """
        public func add_packets(_ packet: (Int16, Int16) -> Void, _ parseable_packet: (Int16, Int16, String?, [Int]) -> Void, PACKETVER: Int, PACKETVER_MAIN_NUM: Int, PACKETVER_RE_NUM: Int, PACKETVER_ZERO_NUM: Int) {
        \(packetdbLines)
        }
        
        """

        let shuffleLine = try outputLines(for: shuffleURL)
            .map({ "    \($0)" })
            .joined(separator: "\n")
        let shuffleOutputContents = """
        public func add_packets_shuffle(_ packet: (Int16, Int16) -> Void, _ parseable_packet: (Int16, Int16, String?, [Int]) -> Void, PACKETVER: Int, PACKETVER_MAIN_NUM: Int, PACKETVER_RE_NUM: Int, PACKETVER_ZERO_NUM: Int) {
        \(shuffleLine)
        }
        
        """

        let packetdbOutputURL = generatedDirectory.appending(path: "packets.swift")
        try packetdbOutputContents.write(to: packetdbOutputURL, atomically: true, encoding: .utf8)

        let shuffleOutputURL = generatedDirectory.appending(path: "packets_shuffle.swift")
        try shuffleOutputContents.write(to: shuffleOutputURL, atomically: true, encoding: .utf8)
    }

    private func outputLines(for inputURL: URL) throws -> [String] {
        var output: [String] = []
        var indentationLevel = 0

        let contents = try String(contentsOf: inputURL, encoding: .utf8)
        let lines = contents.split(separator: "\n")

        for line in lines {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("//") {
                continue
            }

            if line.hasPrefix("packet(") {
                let open = line.firstIndex(of: "(")!
                let close = line.lastIndex(of: ")")!
                let start = line.index(after: open)
                let end = close
                let parameters = line[start..<end]
                    .split(separator: ",")
                    .map({ $0.trimmingCharacters(in: .whitespaces) })
                let packetType = parameters[0]
                let packetLength = parameters[1]

                let indentation = Array(repeating: " ", count: indentationLevel * 4).joined()
                let statement = "packet(\(packetType), \(packetLength))"
                if packetType.hasPrefix("0x") && Int(packetLength) != nil {
                    output.append(indentation + statement)
                } else {
                    output.append(indentation + "// " + statement)
                }
            } else if line.hasPrefix("parseable_packet(") {
                let open = line.firstIndex(of: "(")!
                let close = line.lastIndex(of: ")")!
                let start = line.index(after: open)
                let end = close
                let parameters = line[start..<end]
                    .split(separator: ",")
                    .map({ $0.trimmingCharacters(in: .whitespaces) })
                let packetType = parameters[0]
                let packetLength = parameters[1]
                let functionName = parameters[2] == "nullptr" ? "nil" : "\"\(parameters[2])\""
                let offsets = parameters[3...].joined(separator: ", ")

                let indentation = Array(repeating: " ", count: indentationLevel * 4).joined()
                let statement = "parseable_packet(\(packetType), \(packetLength), \(functionName), [\(offsets)])"
                if packetType.hasPrefix("0x") && Int(packetLength) != nil {
                    output.append(indentation + statement)
                } else {
                    output.append(indentation + "// " + statement)
                }
            } else if line.hasPrefix("#if ") {
                indentationLevel += 1

                let indentation = Array(repeating: " ", count: (indentationLevel - 1) * 4).joined()
                let statement = line
                    .replacingOccurrences(of: "#if ", with: "")
                    .replacingPacketVersion()
                output.append(indentation + "if " + statement + " {")
            } else if line.hasPrefix("#elif") {
                let indentation = Array(repeating: " ", count: (indentationLevel - 1) * 4).joined()
                let statement = line
                    .replacingOccurrences(of: "#elif ", with: "")
                    .replacingPacketVersion()
                output.append(indentation + "} else if " + statement + " {")
            } else if line == "#else" {
                let indentation = Array(repeating: " ", count: (indentationLevel - 1) * 4).joined()
                output.append(indentation + "} else {")
            } else if line == "#endif" {
                let indentation = Array(repeating: " ", count: (indentationLevel - 1) * 4).joined()
                output.append(indentation + "}")

                indentationLevel -= 1
            }
        }

        return output
    }

    // MARK: - Generate Packet Structures

    func generatePacketStructures() throws {
        let dumper = ASTDumper(rathenaDirectory: rathenaDirectory)
        let asts = try [
            dumper.dump(path: "common/packets.hpp"),
            dumper.dump(path: "char/packets.hpp"),
            dumper.dump(path: "map/packets.hpp"),
        ]

        let outputName = "PacketStructures"
        var output = """
        //
        //  \(outputName).swift
        //  RagnarokOffline
        //
        //  Generated by ROCodeGenerator.
        //
        
        import ROCore
        
        """

        var headers: [ASTNode] = []
        for ast in asts {
            let nodes = ast.findNodes {
                $0.kind == "VarDecl" && $0.name != nil && $0.name!.hasPrefix("HEADER_")
            }

            for node in nodes {
                if !headers.contains(where: { $0.name! == node.name! }) {
                    headers.append(node)
                }
            }
        }
        for header in headers {
            let value = header.findNode(where: { $0.kind == "IntegerLiteral" })!.value!.intValue!
            output.append("\n")
            output.append("public let " + header.name! + " = 0x" + String(value, radix: 16))
        }
        output.append("\n")

        var structDecls: [StructDecl] = []
        var referencedStructDecls: [StructDecl] = []

        for ast in asts {
            let nodes = ast.findNodes { node in
                guard node.kind == "CXXRecordDecl" else { return false }
                guard let name = node.name, name.hasPrefix("PACKET_") || name.hasPrefix("packet_") else { return false }
                guard node.inner != nil else { return false }
                return true
            }

            for node in nodes {
                if structDecls.contains(where: { $0.name == node.name }) {
                    continue
                }

                let structDecl = StructDecl(node: node)
                structDecls.append(structDecl)

                for field in structDecl.fields {
                    let structure = switch field.type {
                    case .structure(let structure):
                        structure
                    case .array(let structure):
                        structure
                    case .fixedSizeArray(let structure, _):
                        structure
                    case .string, .fixedLengthString:
                        StructureType.char
                    }
                    guard case .custom(let name) = structure else {
                        continue
                    }
                    guard let node = ast.findNode(where: { $0.kind == "CXXRecordDecl" && $0.name == name && $0.inner != nil }) else {
                        continue
                    }
                    guard !referencedStructDecls.contains(where: { $0.name == node.name }) &&
                        !structDecls.contains(where: { $0.name == node.name }) else {
                        continue
                    }

                    print(name)

                    let structDecl = StructDecl(node: node)
                    referencedStructDecls.append(structDecl)
                }
            }
        }

        for (s, structDecl) in structDecls.enumerated() {
            switch structDecl.name {
            case "PACKET_ZC_POSITION_ID_NAME_INFO":
                var nestedStructDecl = structDecl.nestedStructs[0]
                nestedStructDecl.name = "PACKET_ZC_POSITION_ID_NAME_INFO_sub"
                referencedStructDecls.append(nestedStructDecl)
            case "packet_roulette_info_ack":
                var nestedStructDecl = structDecl.nestedStructs[0]
                nestedStructDecl.name = "packet_roulette_info_ack_sub"
                referencedStructDecls.append(nestedStructDecl)
            default:
                break
            }

            for (f, fieldDecl) in structDecl.fields.enumerated() {
                switch f {
                case 0:
                    switch fieldDecl.name {
                    case "packetType", "PacketType", "packet_id":
                        structDecls[s].fields[f].name = "packetType"
                        structDecls[s].fields[f].type = .structure(.int16)
                    default:
                        break
                    }
                case 1:
                    switch fieldDecl.name {
                    case "packetLength", "PacketLength", "packetLen", "packet_len", "packetSize", "length":
                        structDecls[s].fields[f].name = "packetLength"
                        structDecls[s].fields[f].type = .structure(.int16)
                    default:
                        break
                    }
                default:
                    break
                }

                if structDecl.name == "PACKET_ZC_POSITION_ID_NAME_INFO" && fieldDecl.name == "posInfo" {
                    if case .fixedSizeArray(_, let size) = fieldDecl.type {
                        structDecls[s].fields[f].type = .fixedSizeArray(.custom("PACKET_ZC_POSITION_ID_NAME_INFO_sub"), size)
                    }
                } else if structDecl.name == "packet_roulette_info_ack" && fieldDecl.name == "ItemInfo" {
                    if case .fixedSizeArray(_, let size) = fieldDecl.type {
                        structDecls[s].fields[f].type = .fixedSizeArray(.custom("packet_roulette_info_ack_sub"), size)
                    }
                } else if structDecl.name == "packet_maptypeproperty2" && fieldDecl.name == "flag" {
                    structDecls[s].fields[f].type = structDecl.nestedStructs[0].fields[0].type
                }
            }
        }

        for (s, structDecl) in referencedStructDecls.enumerated() {
            for (f, fieldDecl) in structDecl.fields.enumerated() {
                if structDecl.name == "EQUIPITEM_INFO" && fieldDecl.name == "Flag" {
                    referencedStructDecls[s].fields[f].type = structDecl.nestedStructs[0].fields[0].type
                } else if structDecl.name == "NORMALITEM_INFO" && fieldDecl.name == "Flag" {
                    referencedStructDecls[s].fields[f].type = structDecl.nestedStructs[0].fields[0].type
                }
            }
        }

        for structDecl in structDecls + referencedStructDecls {
            if structDecl.name == "packet_quest_list_info" {
                continue
            }

            var properties: [String] = []
            var decodes: [String] = []
            var encodes: [String] = []

            for (i, field) in structDecl.fields.enumerated() {
                switch field.type {
                case .structure, .array, .string:
                    properties.append("""
                        public var \(field.name): \(field.type.annotation) = \(field.type.initialValue)
                    """)
                case .fixedSizeArray(let structure, let size):
                    properties.append("""
                        @FixedSizeArray(size: \(size), initialValue: \(structure.initialValue))
                        public var \(field.name): \(field.type.annotation)
                    """)
                case .fixedLengthString(let lengthOfBytes):
                    properties.append("""
                        @FixedLengthString(lengthOfBytes: \(lengthOfBytes))
                        public var \(field.name): \(field.type.annotation)
                    """)
                }

                switch field.type {
                case .structure(let structure):
                    decodes.append("""
                            \(field.name) = try decoder.decode(\(structure.name).self)
                    """)
                case .array(let structure):
                    if structDecl.name == "packet_quest_add_header" && field.name == "objectives" {
                        decodes.append("""
                                \(field.name) = try decoder.decode([\(structure.name)].self, count: Int(count))
                        """)
                    } else {
                        let sizes = structDecl.fields[0..<i].map {
                            byteCount(forFieldType: $0.type, structDecls: structDecls + referencedStructDecls)
                        }
                        let remaining = "(Int(packetLength) - (\(sizes.joined(separator: " + "))))"
                        let structByteCount = byteCount(forStructRef: structure, structDecls: structDecls + referencedStructDecls)
                        decodes.append("""
                                \(field.name) = try decoder.decode([\(structure.name)].self, count: \(remaining) / \(structByteCount))
                        """)
                    }
                case .fixedSizeArray(let structure, let size):
                    decodes.append("""
                            \(field.name) = try decoder.decode([\(structure.name)].self, count: \(size))
                    """)
                case .string:
                    let sizes = structDecl.fields[0..<i].map {
                        byteCount(forFieldType: $0.type, structDecls: structDecls + referencedStructDecls)
                    }
                    let remaining = "(Int(packetLength) - (\(sizes.joined(separator: " + "))))"
                    decodes.append("""
                            \(field.name) = try decoder.decode(String.self, lengthOfBytes: \(remaining))
                    """)
                case .fixedLengthString(let lengthOfBytes):
                    decodes.append("""
                            \(field.name) = try decoder.decode(String.self, lengthOfBytes: \(lengthOfBytes))
                    """)
                }

                switch field.type {
                case .structure, .array, .fixedSizeArray, .string:
                    encodes.append("""
                            try encoder.encode(\(field.name))
                    """)
                case .fixedLengthString(let lengthOfBytes):
                    encodes.append("""
                            try encoder.encode(\(field.name), lengthOfBytes: \(lengthOfBytes))
                    """)
                }
            }

            output.append("""
            
            public struct \(structDecl.name): BinaryDecodable, BinaryEncodable, Sendable {
            \(properties.joined(separator: "\n"))
                public init() {
                }
                public init(from decoder: BinaryDecoder) throws {
            \(decodes.joined(separator: "\n"))
                }
                public func encode(to encoder: BinaryEncoder) throws {
            \(encodes.joined(separator: "\n"))
                }
            }
            
            """)
        }

        let outputURL = generatedDirectory.appending(path: "\(outputName).swift")
        try output.write(to: outputURL, atomically: true, encoding: .utf8)
    }

    func byteCount(forFieldType fieldType: FieldType, structDecls: [StructDecl]) -> String {
        switch fieldType {
        case .structure(let structRef):
            byteCount(forStructRef: structRef, structDecls: structDecls)
        case .array:
            "?"
        case .fixedSizeArray(let structRef, let size):
            "(" + byteCount(forStructRef: structRef, structDecls: structDecls) + " * \(size))"
        case .string:
            "?"
        case .fixedLengthString(let lengthOfBytes):
            "\(lengthOfBytes)"
        }
    }

    func byteCount(forStructRef structRef: StructureType, structDecls: [StructDecl]) -> String {
        switch structRef {
        case .char:
            return "1"
        case .int8:
            return "1"
        case .uint8:
            return "1"
        case .int16:
            return "2"
        case .uint16:
            return "2"
        case .int32:
            return "4"
        case .uint32:
            return "4"
        case .int64:
            return "8"
        case .uint64:
            return "8"
        case .float:
            return "4"
        case .double:
            return "8"
        case .custom(let name):
            let structDecl = structDecls.first {
                $0.name == name
            }!
            let size = structDecl.fields.map {
                byteCount(forFieldType: $0.type, structDecls: structDecls)
            }.joined(separator: " + ")
            return "(\(size))"
        }
    }

    // MARK: - Generate Packet Database

    func generatePacketDatabase() throws {
        let dumper = ASTDumper(rathenaDirectory: rathenaDirectory)
        let ast = try dumper.dump(path: "map/clif.cpp")

        let readdb = ast.findFunctionDecl(named: "packetdb_readdb")!
        let addpackets = readdb.findCallExprs(fn: "packetdb_addpacket")
        for addpacket in addpackets {
            let packetType = addpacket.inner![1].findNode { node in
                node.kind == "IntegerLiteral"
            }
            print(packetType?.value?.intValue)

            let packetLength = addpacket.inner![2].findNode { node in
                node.kind == "IntegerLiteral"
            }
            print(packetLength?.value?.intValue)

            let functionName = addpacket.inner![3].findNode { node in
                node.referencedDecl?.kind == "FunctionDecl"
            }
            print(functionName?.referencedDecl?.name)

            let offsets = addpacket.inner![4...].map { node in
                node.findNode(where: { $0.kind == "IntegerLiteral" })!.value!.intValue!
            }
            print(offsets)
        }
    }
}

extension String {
    func replacingPacketVersion() -> String {
        replacingOccurrences(of: "defined(PACKETVER_ZERO)", with: "PACKETVER_ZERO_NUM != 0")
    }
}
