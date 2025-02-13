//
//  AccessoryNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public actor AccessoryNameTable {
    public static let current = AccessoryNameTable()

    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "accessoryid", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "accname", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "accname_f", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }
        } catch {
            print(error)
        }

        return context
    }()

    public func accessoryName(forAccessoryID accessoryID: Int) -> String? {
        guard let result = try? context.call("ReqAccName", with: [accessoryID]) as? String else {
            return nil
        }

        let accessoryName = result.transcoding(from: .isoLatin1, to: .koreanEUC)
        return accessoryName
    }
}
