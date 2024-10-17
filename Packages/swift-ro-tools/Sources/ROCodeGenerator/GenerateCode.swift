//
//  GenerateCode.swift
//  ROCodeGenerator
//
//  Created by Leon Li on 2024/10/10.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

@main
struct GenerateCode: ParsableCommand {
    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var rathenaDirectory: URL

    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var generatedDirectory: URL

    mutating func run() throws {
        try? FileManager.default.removeItem(at: generatedDirectory)
        try? FileManager.default.createDirectory(at: generatedDirectory, withIntermediateDirectories: true)

        try generatePackets()
        try convertConstants()
//        try generatePacketHeaders()
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

    // MARK: - Convert Constants

    func convertConstants() throws {
        let converter = ConstantConverter(rathenaDirectory: rathenaDirectory)
        for conversion in allConstantConversions {
            let outputContents = try converter.convert(conversion: conversion)

            let outputDirectory = generatedDirectory.appending(path: "Constants")
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

            let outputURL = outputDirectory.appending(path: "\(conversion.outputType).swift")
            try outputContents.write(to: outputURL, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - Generate Packet Headers

    func generatePacketHeaders() throws {
        let dumper = ASTDumper(rathenaDirectory: rathenaDirectory)
        let ast = try dumper.dump(path: "common/packets.hpp")

        let headerNodes = ast.findNodes { node in
            node.kind == "VarDecl" && node.name?.hasPrefix("HEADER_") == true
        }
        for node in headerNodes {
            let name = node.name!
            let value = node.findNode(where: { $0.kind == "IntegerLiteral" })!.value!.intValue!
            print(name + " = 0x" + String(value, radix: 16))
        }

        let structNodes = ast.findNodes { node in
            node.kind == "CXXRecordDecl" && node.name?.hasPrefix("PACKET_") == true && node.inner != nil
        }
        for node in structNodes {
            let fields = node.findNodes { node in
                node.kind == "FieldDecl"
            }

            let modifiers = DeclModifierListSyntax(arrayLiteral: DeclModifierSyntax(name: "public"))
            let inheritanceClause = InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Codable"))
            }
            let structDecl = StructDeclSyntax(modifiers: modifiers, name: "\(raw: node.name!)", inheritanceClause: inheritanceClause) {
                fields.map { node in
                    VariableDeclSyntax(modifiers: modifiers, bindingSpecifier: "var") {
                        PatternBindingSyntax(
                            pattern: IdentifierPatternSyntax(identifier: "\(raw: node.name!)"),
                            typeAnnotation: TypeAnnotationSyntax(
                                type: IdentifierTypeSyntax(name: "\(raw: node.type!.asSwiftType!)")
                            )
                        )
                    }
                }
            }
            print(structDecl.formatted().description)
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
