//
//  Option.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/4.
//

public protocol Option: CaseIterable, Decodable, Sendable {
    var stringValue: String { get }

    init?(stringValue: String)
}

extension Option {
    public init?(stringValue: String) {
        if let value = Self.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = value
        } else {
            return nil
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let value = Self.init(stringValue: stringValue) {
            self = value
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(Self.self) does not exist.")
            throw DecodingError.valueNotFound(Self.self, context)
        }
    }
}

extension Set where Element: Option {
    public static var all: Set<Element> {
        Set(Element.allCases)
    }

    public init(from dictionary: [String : Bool]) {
        self = []

        if dictionary.keys.contains("All") {
            formUnion(Element.allCases)
        }

        for (key, value) in dictionary {
            if let option = Element(stringValue: key) {
                if value {
                    insert(option)
                } else {
                    remove(option)
                }
            }
        }
    }
}
