//
//  NetworkPlugin.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

import Foundation
import PackagePlugin

@main
struct NetworkPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let packetdb = context.package.directory.appending(["..", "swift-rathena", "src", "map", "clif_packetdb.hpp"])
        let shuffle = context.package.directory.appending(["..", "swift-rathena", "src", "map", "clif_shuffle.hpp"])

        let packetdb_lines = try output(for: packetdb)
            .map({ "        \($0)" })
            .joined(separator: "\n")
        let packetdb_output = """
        extension PacketDatabase {
            func add_from_clif_packetdb() {
        \(packetdb_lines)
            }
        }
        """

        let shuffle_lines = try output(for: shuffle)
            .map({ "        \($0)" })
            .joined(separator: "\n")
        let shuffle_output = """
        extension PacketDatabase {
            func add_from_clif_shuffle() {
        \(shuffle_lines)
            }
        }
        """

        let packetdb_output_path = context.package.directory.appending(["Sources", "RONetwork", "PacketDatabase", "clif_packetdb_converted.swift"])
        try packetdb_output.write(toFile: packetdb_output_path.string, atomically: true, encoding: .utf8)

        let shuffle_output_path = context.package.directory.appending(["Sources", "RONetwork", "PacketDatabase", "clif_shuffle_converted.swift"])
        try shuffle_output.write(toFile: shuffle_output_path.string, atomically: true, encoding: .utf8)
    }

    private func output(for input: Path) throws -> [String] {
        var output: [String] = []
        var indentationLevel = 0

        let contents = try String(contentsOfFile: input.string, encoding: .utf8)
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
                let statement = "add(\(packetType), \(packetLength))"
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
                let statement = "add(\(packetType), \(packetLength), \(functionName), [\(offsets)])"
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
}

extension String {
    func replacingPacketVersion() -> String {
        replacingOccurrences(of: "defined(PACKETVER_ZERO)", with: "PACKET_VERSION_ZERO_NUMBER != nil")
            .replacingOccurrences(of: "PACKETVER_ZERO_NUM", with: "PACKET_VERSION_ZERO_NUMBER")
            .replacingOccurrences(of: "PACKETVER_MAIN_NUM", with: "PACKET_VERSION_MAIN_NUMBER")
            .replacingOccurrences(of: "PACKETVER_RE_NUM", with: "PACKET_VERSION_RE_NUMBER")
            .replacingOccurrences(of: "PACKETVER", with: "PACKET_VERSION")
    }
}
