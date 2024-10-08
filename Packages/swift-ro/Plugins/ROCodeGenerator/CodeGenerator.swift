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

    struct InputConstant {
        var name: String
        var value: Int
    }

    struct OutputConstant {
        var inputName: String
        var outputName: String
        var intValue: Int
        var stringValues: [String]
        var isExcluded: Bool
    }

    func generateEnums(context: PluginContext) throws {
        var asts: [String : ASTNode] = [:]

        for configuration in configurations {
            try generateEnum(context: context, configuration: configuration, asts: &asts)
        }
    }

    private func generateEnum(context: PluginContext, configuration: Configuration, asts: inout [String : ASTNode]) throws {
        let ast: ASTNode
        if let cachedAST = asts[configuration.source] {
            ast = cachedAST
        } else {
            let srcURL = context.package.directoryURL.appending(path: "../swift-rathena/src")
            let inputURL = srcURL.appending(path: configuration.source)

            let process = Process()
            process.executableURL = try context.tool(named: "clang").url
            process.arguments = ["-Xclang", "-ast-dump=json", "-I" + srcURL.path(), inputURL.path()]

            let pipe = Pipe()
            process.standardOutput = pipe

            try process.run()
//            process.waitUntilExit()

            let data = try pipe.fileHandleForReading.readToEnd()!

            let decoder = JSONDecoder()
            ast = try! decoder.decode(ASTNode.self, from: data)

            asts[configuration.source] = ast
        }

        let enumDecl = ast.findEnumDecl(named: configuration.type)!
        let enumConstantDecls = enumDecl.findEnumConstantDecls()

        var inputConstants: [InputConstant] = []
        for enumConstantDecl in enumConstantDecls {
            var name = enumConstantDecl.name!
            if let replace = configuration.replace[name] {
                name = replace
            }

            let value: Int? = if let value = enumConstantDecl.findConstantExpr()?.value {
                value
            } else if let lastValue = inputConstants.last?.value {
                lastValue + 1
            } else {
                nil
            }

            let constant = InputConstant(name: name, value: value ?? 0)
            inputConstants.append(constant)
        }
        for insert in configuration.insert {
            let constant = InputConstant(name: insert.0, value: insert.1)
            inputConstants.append(constant)
        }

        var outputConstants: [OutputConstant] = []
        for inputConstant in inputConstants {
            let inputName = inputConstant.name

            var outputName = inputName
            if outputName.hasPrefix(configuration.prefix) {
                outputName = String(outputName.dropFirst(configuration.prefix.count))
            }
            if outputName.hasSuffix(configuration.suffix) {
                outputName = String(outputName.dropLast(configuration.suffix.count))
            }
            if let outputPrefix = configuration.outputPrefix {
                outputName = outputPrefix + outputName
            }
            outputName = outputName.lowercased()
            let digits = try Regex("[0-9]+")
            if outputName.starts(with: digits) {
                outputName = "_" + outputName
            } else if outputName == "class" || outputName == "self" {
                outputName = "_" + outputName
            }

            var stringValues = [inputName]
            if let compatible = configuration.compatible[inputName] {
                stringValues.append(contentsOf: compatible)
            }
            stringValues = stringValues.map {
                var stringValue = $0
                if stringValue.hasPrefix(configuration.prefix) {
                    stringValue = String(stringValue.dropFirst(configuration.prefix.count))
                }
                if stringValue.hasSuffix(configuration.suffix) {
                    stringValue = String(stringValue.dropLast(configuration.suffix.count))
                }
                return stringValue
            }

            let constant = OutputConstant(
                inputName: inputName,
                outputName: outputName,
                intValue: inputConstant.value,
                stringValues: stringValues,
                isExcluded: configuration.exclude.contains(inputConstant.name)
            )
            outputConstants.append(constant)
        }
        outputConstants = outputConstants.filter {
            !$0.isExcluded
        }

        var outputContents = ""

        switch configuration.kind {
        case .cEnum:
            outputContents = """
            //
            //  \(configuration.outputType).swift
            //  RagnarokOffline
            //
            //  Generated by ROCodeGenerator.
            //
            
            /// Converted from `\(configuration.type)` in `\(configuration.source)`.
            
            """

            if configuration.extensions.contains(.rawRepresentable) {
                let casesContents = outputConstants
                    .map {
                        "    case \($0.outputName)"
                    }
                    .joined(separator: "\n")

                let rawValueContents = outputConstants
                    .map {
                        let value = switch configuration.outputFormat {
                        case .decimal:
                            String($0.intValue, radix: 10)
                        case .hex:
                            "0x" + String($0.intValue, radix: 16)
                        }
                        return "        case .\($0.outputName): \(value)"
                    }
                    .joined(separator: "\n")

                let initRawValueContents = outputConstants
                    .map {
                        let value = switch configuration.outputFormat {
                        case .decimal:
                            String($0.intValue, radix: 10)
                        case .hex:
                            "0x" + String($0.intValue, radix: 16)
                        }
                        return "        case \(value): self = .\($0.outputName)"
                    }
                    .joined(separator: "\n")

                outputContents.append("""
                public enum \(configuration.outputType): CaseIterable, Sendable {
                \(casesContents)
                }
                
                extension \(configuration.outputType): RawRepresentable {
                    public var rawValue: Int {
                        switch self {
                \(rawValueContents)
                        }
                    }
                
                    public init?(rawValue: Int) {
                        switch rawValue {
                \(initRawValueContents)
                        default: return nil
                        }
                    }
                }
                
                """)
            } else {
                let casesContents = outputConstants
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

                outputContents.append("""
                public enum \(configuration.outputType): Int, CaseIterable, Sendable {
                \(casesContents)
                }
                
                """)
            }

            if configuration.extensions.contains(.decodable) {
                let stringValueContents = outputConstants
                    .map {
                        "        case .\($0.outputName): \"\($0.stringValues[0])\""
                    }
                    .joined(separator: "\n")

                let initStringValueContents = outputConstants
                    .map {
                        let stringValues = $0.stringValues
                            .map {
                                "\"\($0)\""
                            }
                            .joined(separator: ", ")

                        return "        case " + stringValues + ": self = .\($0.outputName)"
                    }
                    .joined(separator: "\n")

                outputContents.append("""
                
                extension \(configuration.outputType): CodingKey {
                    public var stringValue: String {
                        switch self {
                \(stringValueContents)
                        }
                    }
                
                    public init?(stringValue: String) {
                        switch stringValue.uppercased() {
                \(initStringValueContents)
                        default: return nil
                        }
                    }
                
                    public var intValue: Int? {
                        rawValue
                    }
                
                    public init?(intValue: Int) {
                        self.init(rawValue: intValue)
                    }
                }
                
                extension \(configuration.outputType): CodingKeyRepresentable {
                    public var codingKey: any CodingKey {
                        self
                    }
                
                    public init?<T>(codingKey: T) where T: CodingKey {
                        self.init(stringValue: codingKey.stringValue)
                    }
                }
                
                extension \(configuration.outputType): Decodable {
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
                
                """)
            }
        case .optionSet:
            outputContents = """
            //
            //  \(configuration.outputType).swift
            //  RagnarokOffline
            //
            //  Generated by ROCodeGenerator.
            //
            
            /// Converted from `\(configuration.type)` in `\(configuration.source)`.
            
            """

            let casesContents = outputConstants
                .map {
                    let value = "0x" + String($0.intValue, radix: 16)
                    return "    public static let \($0.outputName) = \(configuration.outputType)(rawValue: \(value))"
                }
                .joined(separator: "\n")

            outputContents.append("""
            public struct \(configuration.outputType): OptionSet, Hashable, Sendable {
            \(casesContents)
            
                public let rawValue: Int
            
                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            
            """)

            if configuration.extensions.contains(.decodable) {
                let stringValueContents = outputConstants
                    .map {
                        "        case .\($0.outputName): \"\($0.stringValues[0])\""
                    }
                    .joined(separator: "\n")

                let initStringValueContents = outputConstants
                    .map {
                        let stringValues = $0.stringValues
                            .map {
                                "\"\($0)\""
                            }
                            .joined(separator: ", ")

                        return "        case " + stringValues + ": self = .\($0.outputName)"
                    }
                    .joined(separator: "\n")

                outputContents.append("""
                
                extension \(configuration.outputType): CodingKey {
                    public var stringValue: String {
                        switch self {
                \(stringValueContents)
                        default: ""
                        }
                    }
                
                    public init?(stringValue: String) {
                        switch stringValue.uppercased() {
                \(initStringValueContents)
                        default: return nil
                        }
                    }
                
                    public var intValue: Int? {
                        rawValue
                    }
                
                    public init?(intValue: Int) {
                        self.init(rawValue: intValue)
                    }
                }
                
                extension \(configuration.outputType): Decodable {
                    public init(from decoder: any Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        let dictionary = try container.decode([String : Bool].self)
                        let trueKeys = dictionary.compactMap {
                            $0.value ? $0.key : nil
                        }
                        let falseKeys = dictionary.compactMap {
                            !$0.value ? $0.key : nil
                        }

                        self.rawValue = 0
                        for trueKey in trueKeys {
                            if let member = \(configuration.outputType)(stringValue: trueKey) {
                                self.insert(member)
                            }
                        }
                        for falseKey in falseKeys {
                            if let member = \(configuration.outputType)(stringValue: falseKey) {
                                self.remove(member)
                            }
                        }
                    }
                }
                
                """)
            }
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
