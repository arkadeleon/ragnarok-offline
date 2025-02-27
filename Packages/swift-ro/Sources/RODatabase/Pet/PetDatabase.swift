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

    private lazy var _pets: [Pet] = {
        do {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/pet_db.yml")
            let data = try Data(contentsOf: url)
            let pets = try decoder.decode(ListNode<Pet>.self, from: data).body

            return pets
        } catch {
            logger.warning("\(error.localizedDescription)")
            return []
        }
    }()

    private lazy var _petsByAegisName: [String : Pet] = {
        Dictionary(
            _pets.map({ ($0.monster, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func pets() -> [Pet] {
        _pets
    }

    public func pet(forAegisName aegisName: String) -> Pet? {
        _petsByAegisName[aegisName]
    }
}
