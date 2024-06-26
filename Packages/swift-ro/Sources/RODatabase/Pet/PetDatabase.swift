//
//  PetDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Foundation
import rAthenaCommon
import rAthenaResources

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

    private var cachedPets: [Pet] = []
    private var cachedPetsByAegisNames: [String : Pet] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func pets() throws -> [Pet] {
        if cachedPets.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("pet_db.yml")
            let data = try Data(contentsOf: url)
            cachedPets = try decoder.decode(ListNode<Pet>.self, from: data).body
        }

        return cachedPets
    }

    public func pet(forAegisName aegisName: String) throws -> Pet? {
        if cachedPetsByAegisNames.isEmpty {
            let pets = try pets()
            cachedPetsByAegisNames = Dictionary(pets.map({ ($0.monster, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let pet = cachedPetsByAegisNames[aegisName]
        return pet
    }
}
