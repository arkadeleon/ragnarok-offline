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

        var structures: [ASTNode] = []
        var referencedStructures: [ASTNode] = []
        for ast in asts {
            let nodes = ast.findNodes { node in
                guard node.kind == "CXXRecordDecl" else { return false }
                guard let name = node.name, name.hasPrefix("PACKET_") else { return false }
                guard node.inner != nil else { return false }
                return true
            }

            for node in nodes {
                if structures.contains(where: { $0.name! == node.name! }) {
                    continue
                }

                structures.append(node)

                let fields = node.findNodes { node in
                    node.kind == "FieldDecl"
                }
                for field in fields {
                    let type = field.type!.asSwiftType!
                    let structure = switch type {
                    case .structure(let structure):
                        structure
                    case .structureArray(let structure):
                        structure
                    case .fixedSizeStructureArray(let structure, _):
                        structure
                    }
                    if case .custom(let name) = structure {
                        print(name)
                        guard let node = ast.findNode(where: { $0.kind == "CXXRecordDecl" && $0.name == name && $0.inner != nil }) else {
                            continue
                        }
                        if !referencedStructures.contains(where: { $0.name == node.name }) &&
                            !structures.contains(where: { $0.name == node.name }) {
                            referencedStructures.append(node)
                        }
                    }
                }
            }
        }

        for structure in structures + referencedStructures {
            let fields = structure.findNodes { node in
                node.kind == "FieldDecl"
            }

            let modifiers = DeclModifierListSyntax(arrayLiteral: DeclModifierSyntax(name: "public"))
            let inheritanceClause = InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Sendable"))
            }
            let structDecl = try StructDeclSyntax(modifiers: modifiers, name: "\(raw: structure.name!)", inheritanceClause: inheritanceClause) {
                fields.map { field in
                    var fieldType = field.type!.asSwiftType!
                    if structure.name == "PACKET_ZC_POSITION_ID_NAME_INFO" && field.name == "posInfo" {
                        fieldType = .fixedSizeStructureArray(.custom("PACKET_ZC_POSITION_ID_NAME_INFO_sub"), 20)
                    }
                    if structure.name == "EQUIPITEM_INFO" && field.name == "Flag" {
                        fieldType = .structure(.standard("UInt8"))
                    }


                    let attributes = AttributeListSyntax {
                        for attribute in fieldType.attributes {
                            AttributeSyntax(stringLiteral: attribute)
                        }
                    }
                    return VariableDeclSyntax(attributes: attributes, modifiers: modifiers, bindingSpecifier: "var") {
                        PatternBindingSyntax(
                            pattern: IdentifierPatternSyntax(identifier: "\(raw: field.name!)"),
                            typeAnnotation: TypeAnnotationSyntax(
                                type: IdentifierTypeSyntax(name: "\(raw: fieldType.annotation)")
                            )
                        )
                    }
                }

                try InitializerDeclSyntax("public init()") {
                    for node in fields where !node.type!.isFixedSizeArray {
                        InfixOperatorExprSyntax(
                            leftOperand: DeclReferenceExprSyntax(baseName: "\(raw: node.name!)"),
                            operator: AssignmentExprSyntax(),
                            rightOperand: FunctionCallExprSyntax(calledExpression: MemberAccessExprSyntax(name: "init()"), arguments: LabeledExprListSyntax())
                        )
                    }
                }
            }
            output.append("\n")
            output.append(structDecl.formatted().description)
            output.append("\n")
        }

        output.append("\n")
        output.append("""
            public struct PACKET_ZC_POSITION_ID_NAME_INFO_sub: Sendable {
                public var positionID: Int32
                @FixedSizeArray(size: 24, initialValue: .init())
                public var posName: [Int8]
                public init() {
                    positionID = .init()
                }
            }
            """)
        output.append("\n")

        let outputURL = generatedDirectory.appending(path: "\(outputName).swift")
        try output.write(to: outputURL, atomically: true, encoding: .utf8)
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
