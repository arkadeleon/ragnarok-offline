//
//  Generator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

import Foundation
import PackagePlugin

@main
struct Generator: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let url = context.package.directoryURL.appending(path: "Sources/ROGenerated")
        try FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        try generatePackets(context: context)
        try generateEnums(context: context)
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

    // MARK: - Generate Enums

    struct Case {
        var name: String
        var outputName: String
        var intValue: Int
        var stringValues: [String]
        var isExcluded: Bool
    }

    func generateEnums(context: PluginContext) throws {
        for configuration in configurations {
            try generateEnum(context: context, configuration: configuration)
        }
    }

    private func generateEnum(context: PluginContext, configuration: Configuration) throws {
        var cases: [Case] = []

        let srcURL = context.package.directoryURL.appending(path: "../swift-rathena/src")
        let inputURL = srcURL.appending(path: configuration.path)

        let process = Process()
        process.executableURL = try context.tool(named: "clang").url
        process.arguments = ["-Xclang", "-ast-dump=json", "-I" + srcURL.path(), inputURL.path()]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
//        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd()!

        let decoder = JSONDecoder()
        let root = try! decoder.decode(ASTNode.self, from: data)

        let enumDecl = root.findEnumDecl(named: configuration.type)!
        let enumConstantDecls = enumDecl.findEnumConstantDecls()

        for enumConstantDecl in enumConstantDecls {
            let name = enumConstantDecl.name!

            var outputName = name
            if outputName.starts(with: configuration.prefix) {
                outputName = String(outputName.dropFirst(configuration.prefix.count))
            }
            let digits = try Regex("[0-9]+")
            if outputName.starts(with: digits) {
                outputName = "_" + outputName
            } else if outputName.lowercased() == "class" {
                outputName = "_" + outputName
            }
            outputName = outputName.lowercased()

            let intValue: Int? = if let intValue = enumConstantDecl.findConstantExpr()?.value {
                intValue
            } else if let lastIntValue = cases.last?.intValue {
                lastIntValue + 1
            } else {
                nil
            }

            var stringValues = [name]
            if let compatibles = configuration.compatibles[name] {
                stringValues.append(contentsOf: compatibles)
            }

            let c = Case(
                name: name,
                outputName: outputName,
                intValue: intValue ?? 0,
                stringValues: stringValues,
                isExcluded: configuration.excludes.contains(name)
            )
            cases.append(c)
        }

        let outputCases = cases
            .filter {
                !$0.isExcluded
            }

        let casesContents = outputCases
            .map {
                let value = switch configuration.outputFormat {
                case .decimal:
                    String($0.intValue, radix: 10)
                case .hex:
                    "0x" + String($0.intValue, radix: 16)
                }
                return "    case \($0.outputName) = \(value)"
            }
            .joined(separator: "\n")

        let stringValueContents = outputCases
            .map {
                let stringValues = $0.stringValues
                    .map {
                        var stringValue = $0

                        if stringValue.starts(with: configuration.prefix) {
                            stringValue = String(stringValue.dropFirst(configuration.prefix.count))
                        }

                        return "\"\(stringValue)\""
                    }
                    .joined(separator: ", ")

                return "        case " + stringValues + ": self = .\($0.outputName)"
            }
            .joined(separator: "\n")

        let outputContents: String
        if configuration.isDecodable {
            outputContents = """
            //
            //  \(configuration.outputType).swift
            //  RagnarokOffline
            //
            //  Generated by ROGenerator.
            //

            public enum \(configuration.outputType): Int, CaseIterable, CodingKey, CodingKeyRepresentable, Decodable, Sendable {
            \(casesContents)

                public init?(stringValue: String) {
                    switch stringValue.uppercased() {
            \(stringValueContents)
                    default: return nil
                    }
                }

                public init?<T>(codingKey: T) where T: CodingKey {
                    self.init(stringValue: codingKey.stringValue)
                }

                public init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let stringValue = try container.decode(String.self)
                    if let value = Self.init(stringValue: stringValue) {
                        self = value
                    } else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not initialize \\(Self.self) from invalid string value \\(stringValue)")
                    }
                }
            }
            """
        } else {
            outputContents = """
            //
            //  \(configuration.outputType).swift
            //  RagnarokOffline
            //
            //  Generated by ROGenerator.
            //

            public enum \(configuration.outputType): Int, CaseIterable, Sendable {
            \(casesContents)
            }
            """
        }

        let outputDirectory = context.package.directoryURL.appending(path: "Sources/ROGenerated/Constants")
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let outputURL = outputDirectory.appending(path: "\(configuration.outputType).swift")
        try outputContents.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}

extension String {
    func replacingPacketVersion() -> String {
        replacingOccurrences(of: "defined(PACKETVER_ZERO)", with: "PACKETVER_ZERO_NUM != 0")
    }
}
