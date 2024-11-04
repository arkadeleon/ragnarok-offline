//
//  PetDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Foundation
import rAthenaResources

public actor PetDatabase {
    public static let prerenewal = PetDatabase(mode: .prerenewal)
    public static let renewal = PetDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> PetDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private var cachedPets: [Pet] = []
    private var cachedPetsByAegisName: [String : Pet] = [:]

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func pets() throws -> [Pet] {
        if cachedPets.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.path)
                .appendingPathComponent("pet_db.yml")
            let data = try Data(contentsOf: url)
            cachedPets = try decoder.decode(ListNode<Pet>.self, from: data).body
        }

        return cachedPets
    }

    public func pet(forAegisName aegisName: String) throws -> Pet? {
        if cachedPetsByAegisName.isEmpty {
            let pets = try pets()
            cachedPetsByAegisName = Dictionary(pets.map({ ($0.monster, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let pet = cachedPetsByAegisName[aegisName]
        return pet
    }
}
