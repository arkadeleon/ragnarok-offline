//
//  ShadowFactorTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public actor ShadowFactorTable {
    public static let current = ShadowFactorTable()

    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "jobidentity", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "npcidentity", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "shadowtable", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            try context.parse("""
            function shadowFactor(jobID)
                return ShadowFactorTable[jobID]
            end
            """)
        } catch {
            print(error)
        }

        return context
    }()

    public func shadowFactor(forJobID jobID: Int) -> Double? {
        let result = try? context.call("shadowFactor", with: [jobID]) as? Double
        return result
    }
}
