//
//  WeaponNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public let weaponNameTable = WeaponNameTable()

public actor WeaponNameTable {
    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "weapontable", withExtension: "lub", locale: .korean) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            try context.parse("""
            function weaponName(weaponID)
                return WeaponNameTable[weaponID]
            end
            """)
        } catch {
            print(error)
        }

        return context
    }()

    public func weaponName(forWeaponID weaponID: Int) -> String? {
        guard let result = try? context.call("weaponName", with: [weaponID]) as? String else {
            return nil
        }

        let weaponName = result.transcoding(from: .isoLatin1, to: .koreanEUC)
        return weaponName
    }
}
