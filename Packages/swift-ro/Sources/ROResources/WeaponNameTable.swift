//
//  WeaponNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public actor WeaponNameTable {
    public static let current = WeaponNameTable()

    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "weapontable", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "weapontable_f", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        return context
    }()

    public func weaponName(forWeaponID weaponID: Int) -> String? {
        guard let result = try? context.call("ReqWeaponName", with: [weaponID]) as? String else {
            return nil
        }

        let weaponName = result.transcoding(from: .isoLatin1, to: .koreanEUC)
        return weaponName
    }

    public func realWeaponID(forWeaponID weaponID: Int) -> Int? {
        guard let result = try? context.call("GetRealWeaponId", with: [weaponID]) as? Int else {
            return nil
        }

        return result
    }
}
