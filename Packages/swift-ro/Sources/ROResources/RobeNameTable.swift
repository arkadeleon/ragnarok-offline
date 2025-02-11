//
//  RobeNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public actor RobeNameTable {
    public static let current = RobeNameTable()

    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "spriterobeid", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "spriterobename", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            try context.parse("""
            function robeName(robeID)
                return RobeNameTable[robeID]
            end
            """)
        } catch {
            print(error)
        }

        return context
    }()

    public func robeName(forRobeID robeID: Int) -> String? {
        guard let result = try? context.call("robeName", with: [robeID]) as? String else {
            return nil
        }

        let robeName = result.transcoding(from: .isoLatin1, to: .koreanEUC)
        return robeName
    }
}
