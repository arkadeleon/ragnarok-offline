//
//  PetDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Foundation
import rAthenaCommon
import rAthenaResource
import rAthenaRyml

public actor PetDatabase {
    public static let prerenewal = PetDatabase(mode: .prerenewal)
    public static let renewal = PetDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> PetDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var pets: [Pet] = []
    private var petsByAegisNames: [String : Pet] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func allPets() throws -> [Pet] {
        if pets.isEmpty {
            let decoder = YAMLDecoder()

            let url = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("pet_db.yml")
            let data = try Data(contentsOf: url)
            pets = try decoder.decode(ListNode<Pet>.self, from: data).body
        }

        return pets
    }

    public func pet(forAegisName aegisName: String) async throws -> Pet {
        if petsByAegisNames.isEmpty {
            let pets = try allPets()
            petsByAegisNames = Dictionary(pets.map({ ($0.monster.uppercased(), $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let pet = petsByAegisNames[aegisName.uppercased()] {
            return pet
        } else {
            throw DatabaseError.recordNotFound
        }
    }
}
