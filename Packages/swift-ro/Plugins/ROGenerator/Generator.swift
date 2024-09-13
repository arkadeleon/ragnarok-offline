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
        var intValue: Int
        var stringValues: [String]
        var isExcluded: Bool
    }

    struct Configuration {
        var path: String
        var type: String
        var prefix: String
        var compatibles: [String : [String]] = [:]
        var excludes: [String] = []
        var exportedType: String
        var isDecodable = true
    }

    func generateEnums(context: PluginContext) throws {
        let configurations: [Configuration] = [
            .init(
                path: "common/mmo.hpp",
                type: "item_types",
                prefix: "IT_",
                excludes: ["IT_UNKNOWN", "IT_UNKNOWN2", "IT_MAX"],
                exportedType: "ItemType"
            ),
            .init(
                path: "common/mmo.hpp",
                type: "e_job",
                prefix: "JOB_",
                compatibles: ["JOB_SUPER_NOVICE": ["JOB_SUPERNOVICE"]],
                excludes: ["JOB_MAX_BASIC", "JOB_MAX"],
                exportedType: "Job"
            ),
            .init(
                path: "map/map.hpp",
                type: "_sp",
                prefix: "SP_",
                exportedType: "StatusProperty",
                isDecodable: false
            ),
            .init(
                path: "common/mmo.hpp",
                type: "e_sex",
                prefix: "SEX_",
                excludes: ["SEX_SERVER"],
                exportedType: "Sex"
            ),
        ]

        for configuration in configurations {
            try generateEnum(context: context, configuration: configuration)
        }
    }

    private func generateEnum(context: PluginContext, configuration: Configuration) throws {
        var cases: [Case] = []
        var typeFound = false

        let inputURL = context.package.directoryURL.appending(path: "../swift-rathena/src").appending(path: configuration.path)
        let inputContents = try String(contentsOf: inputURL, encoding: .utf8)
        let lines = inputContents.split(separator: "\n")
        for line in lines {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("//") {
                continue
            }
            if line.hasPrefix("enum " + configuration.type) {
                typeFound = true
                continue
            }
            if typeFound, line.starts(with: configuration.prefix) {
                let components = line.split(separator: ",")
                for component in components {
                    let component = component
                        .trimmingCharacters(in: .whitespaces)
                    if component.hasPrefix("//") {
                        continue
                    }
                    let nameAndValue = component
                        .split(separator: "=")
                    if nameAndValue.count > 0 {
                        let name = nameAndValue[0]
                            .trimmingCharacters(in: .whitespaces)
                        let nameWithoutPrefix = name.dropFirst(configuration.prefix.count)
                        var caseName = nameWithoutPrefix.lowercased()
                        let digits = try Regex("[0-9]+")
                        if caseName.starts(with: digits) {
                            caseName = "_" + caseName
                        } else if caseName == "class" {
                            caseName = "_" + caseName
                        }
                        let intValue: Int? = if nameAndValue.count > 1 {
                            Int(nameAndValue[1].trimmingCharacters(in: .whitespaces))
                        } else if let lastIntValue = cases.last?.intValue {
                            lastIntValue + 1
                        } else {
                            nil
                        }
                        var stringValues = [String(nameWithoutPrefix)]
                        if let compatibles = configuration.compatibles[name] {
                            let compatibles = compatibles
                                .map({ $0.dropFirst(configuration.prefix.count) })
                                .map(String.init)
                            stringValues.append(contentsOf: compatibles)
                        }
                        let c = Case(
                            name: String(caseName),
                            intValue: intValue ?? 0,
                            stringValues: stringValues,
                            isExcluded: configuration.excludes.contains(name)
                        )
                        cases.append(c)
                    }
                }
            }
            if typeFound, line == "};" {
                break
            }
        }

        let outputCases = cases
            .filter {
                !$0.isExcluded
            }

        let casesContents = outputCases
            .map {
                "    case \($0.name) = \($0.intValue)"
            }
            .joined(separator: "\n")

        let stringValueContents = outputCases
            .map {
                "        case " + $0.stringValues.map({ "\"\($0)\"" }).joined(separator: ", ") + ": self = .\($0.name)"
            }
            .joined(separator: "\n")

        let outputContents: String
        if configuration.isDecodable {
            outputContents = """
            //
            //  \(configuration.exportedType).swift
            //  RagnarokOffline
            //
            //  Generated by ROGenerator.
            //

            public enum \(configuration.exportedType): Int, CaseIterable, CodingKey, CodingKeyRepresentable, Decodable, Sendable {
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
            //  \(configuration.exportedType).swift
            //  RagnarokOffline
            //
            //  Generated by ROGenerator.
            //

            public enum \(configuration.exportedType): Int, CaseIterable, Sendable {
            \(casesContents)
            }
            """
        }

        let outputURL = context.package.directoryURL.appending(path: "Sources/ROGenerated/\(configuration.exportedType).swift")
        try outputContents.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}

extension String {
    func replacingPacketVersion() -> String {
        replacingOccurrences(of: "defined(PACKETVER_ZERO)", with: "PACKETVER_ZERO_NUM != 0")
    }
}
