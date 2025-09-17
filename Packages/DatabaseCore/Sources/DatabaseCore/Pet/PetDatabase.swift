//
//  PetDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Foundation
import RapidYAML

public actor PetDatabase {
    public let sourceURL: URL
    public let mode: DatabaseMode

    private lazy var _pets: [Pet] = {
        metric.beginMeasuring("Load pet database")

        do {
            let decoder = YAMLDecoder()

            let url = sourceURL.appending(path: "db/\(mode.path)/pet_db.yml")
            let data = try Data(contentsOf: url)
            let pets = try decoder.decode(ListNode<Pet>.self, from: data).body

            metric.endMeasuring("Load pet database")

            return pets
        } catch {
            metric.endMeasuring("Load pet database", error)

            return []
        }
    }()

    private lazy var _petsByAegisName: [String : Pet] = {
        Dictionary(
            _pets.map({ ($0.monster, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    public init(sourceURL: URL, mode: DatabaseMode) {
        self.sourceURL = sourceURL
        self.mode = mode
    }

    public func pets() -> [Pet] {
        _pets
    }

    public func pet(forAegisName aegisName: String) -> Pet? {
        _petsByAegisName[aegisName]
    }
}
