//
//  ItemCombo.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/24.
//

public struct ItemCombo: Decodable, Equatable, Hashable, Sendable {

    /// List of combo sets.
    public var combos: [ItemCombo.Combo]

    /// Script to execute when one of the combos is equipped. (Default: null)
    public var script: String?

    /// Remove the defined combos from database. (Default: false)
    public var clear: Bool

    enum CodingKeys: String, CodingKey {
        case combos = "Combos"
        case script = "Script"
        case clear = "Clear"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.combos = try container.decode([ItemCombo.Combo].self, forKey: .combos)
        self.script = try container.decodeIfPresent(String.self, forKey: .script)
        self.clear = try container.decodeIfPresent(Bool.self, forKey: .clear) ?? false
    }
}

extension ItemCombo {

    /// Combo set.
    public struct Combo: Decodable, Equatable, Hashable, Sendable {

        /// Sequence of items to define a combo (minimum of 2 items).
        public var combo: [String]

        enum CodingKeys: String, CodingKey {
            case combo = "Combo"
        }
    }
}
