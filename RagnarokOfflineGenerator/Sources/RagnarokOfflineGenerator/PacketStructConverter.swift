//
//  PacketStructConverter.swift
//  RagnarokOfflineGenerator
//
//  Created by Leon Li on 2025/4/9.
//

class PacketStructConverter {
    let structDecls: [StructDecl]

    init(structDecls: [StructDecl]) {
        self.structDecls = structDecls
    }

    func convertAll() -> [String] {
        var outputs: [String] = []

        for structDecl in structDecls {
            let protocols = if structDecl.fields.first?.name == "packetType" {
                "CodablePacket"
            } else {
                "BinaryDecodable, BinaryEncodable, Sendable"
            }

            var properties: [String] = []
            var decodes: [String] = []
            var encodes: [String] = []

            for (f, field) in structDecl.fields.enumerated() {
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

                var decodeExpr = ""
                switch field.type {
                case .structure(let structure):
                    decodeExpr = """
                            \(field.name) = try decoder.decode(\(structure.name).self)
                    """
                case .array(let structure):
                    let sizes = structDecl.fields[0..<f].map {
                        byteCount(forFieldType: $0.type)
                    }
                    let remaining = "(Int(packetLength) - (\(sizes.joined(separator: " + "))))"
                    let structByteCount = byteCount(forStructRef: structure)
                    decodeExpr = """
                            \(field.name) = try decoder.decode([\(structure.name)].self, count: \(remaining) / \(structByteCount))
                    """
                case .fixedSizeArray(let structure, let size):
                    decodeExpr = """
                            \(field.name) = try decoder.decode([\(structure.name)].self, count: \(size))
                    """
                case .string:
                    let sizes = structDecl.fields[0..<f].map {
                        byteCount(forFieldType: $0.type)
                    }
                    let remaining = "(Int(packetLength) - (\(sizes.joined(separator: " + "))))"
                    decodeExpr = """
                            \(field.name) = try decoder.decode(String.self, lengthOfBytes: \(remaining))
                    """
                case .fixedLengthString(let lengthOfBytes):
                    decodeExpr = """
                            \(field.name) = try decoder.decode(String.self, lengthOfBytes: \(lengthOfBytes))
                    """
                }
                if structDecl.name == "packet_quest_add_header", field.name == "objectives" {
                    decodeExpr = """
                            \(field.name) = try decoder.decode([\(field.type.structRef!.name)].self, count: Int(count))
                    """
                }
                decodes.append(decodeExpr)

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

            outputs.append("""
            public struct \(structDecl.name): \(protocols) {
                public static var size: Int {
                    \(byteCount(forCustomStructNamed: structDecl.name))
                }
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

        return outputs
    }

    private func byteCount(forCustomStructNamed name: String) -> String {
        let structDecl = structDecls.first {
            $0.name == name
        }!
        let size = structDecl.fields.map {
            byteCount(forFieldType: $0.type)
        }.joined(separator: " + ")
        return size.contains("?") ? "-1" : "(\(size))"
    }

    private func byteCount(forStructRef structRef: StructureType) -> String {
        switch structRef {
        case .char:
            "1"
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
        case .custom(let name):
            "\(name).size"
        }
    }

    private func byteCount(forFieldType fieldType: FieldType) -> String {
        switch fieldType {
        case .structure(let structRef):
            byteCount(forStructRef: structRef)
        case .array:
            "?"
        case .fixedSizeArray(let structRef, let size):
            "(" + byteCount(forStructRef: structRef) + " * \(size))"
        case .string:
            "?"
        case .fixedLengthString(let lengthOfBytes):
            "\(lengthOfBytes)"
        }
    }
}
