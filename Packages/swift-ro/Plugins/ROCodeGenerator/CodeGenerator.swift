//
//  CodeGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

import Foundation
import PackagePlugin

@main
struct CodeGenerator: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let url = context.package.directoryURL.appending(path: "Sources/ROGenerated")
        try FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        try generatePackets(context: context)
        try convertConstants(context: context)
//        try generatePacketDatabase(context: context)
    }

    // MARK: - Generate Packet Database

    private func generatePackets(context: PluginContext) throws {
        let packetdbURL = context.package.directoryURL.appending(path: "../swift-rathena/src/map/clif_packetdb.hpp")
        let shuffleURL = context.package.directoryURL.appending(path: "../swift-rathena/src/map/clif_shuffle.hpp")

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

        let packetdbOutputURL = context.package.directoryURL.appending(path: "Sources/ROGenerated/packets.swift")
        try packetdbOutputContents.write(to: packetdbOutputURL, atomically: true, encoding: .utf8)

        let shuffleOutputURL = context.package.directoryURL.appending(path: "Sources/ROGenerated/packets_shuffle.swift")
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

    func convertConstants(context: PluginContext) throws {
        let converter = ConstantConverter()
        for conversion in allConstantConversions {
            try converter.convert(context: context, conversion: conversion)
        }
    }

    // MARK: - Generate Packet Database

    func generatePacketDatabase(context: PluginContext) throws {
        let dumper = ASTDumper()
        let ast = try dumper.dump(context: context, path: "map/clif.cpp")

        let readdb = ast.findFunctionDecl(named: "packetdb_readdb")!
        let addpackets = readdb.findCallExprs(fn: "packetdb_addpacket")
        for addpacket in addpackets {
            let packetType = addpacket.inner![1].findNode { node in
                node.kind == "IntegerLiteral"
            }
            print(packetType?.value)

            let packetLength = addpacket.inner![2].findNode { node in
                node.kind == "IntegerLiteral"
            }
            print(packetLength?.value)

            let functionName = addpacket.inner![3].findNode { node in
                node.referencedDecl?.kind == "FunctionDecl"
            }
            print(functionName?.referencedDecl?.name)

            let offsets = addpacket.inner![4...].map { node in
                node.findNode(where: { $0.kind == "IntegerLiteral" })!.value!
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
