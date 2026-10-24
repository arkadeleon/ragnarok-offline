//
//  ArrowCrafting.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/25.
//

public struct ArrowCrafting: Decodable, Equatable, Hashable, Sendable {

    /// AegisName of the item that is consumed.
    public var source: String

    /// List of item(s) received by the player.
    public var make: [ArrowCrafting.Make]

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case make = "Make"
    }
}

extension ArrowCrafting {

    /// Item received by the player.
    public struct Make: Decodable, Equatable, Hashable, Sendable {

        /// AegisName of the item received.
        public var item: String

        /// Amount of Item received. (Use 0 to remove the Item on import)
        public var amount: Int

        enum CodingKeys: String, CodingKey {
            case item = "Item"
            case amount = "Amount"
        }
    }
}
