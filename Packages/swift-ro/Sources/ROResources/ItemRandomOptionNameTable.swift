//
//  ItemRandomOptionNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public actor ItemRandomOptionNameTable {
    public static let current = ItemRandomOptionNameTable(locale: .current)

    let locale: Locale

    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "enumvar", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "addrandomoptionnametable", withExtension: "lub", locale: .korean) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            try context.parse("""
            function itemRandomOptionName(itemRandomOptionID)
                return NameTable_VAR[itemRandomOptionID]
            end
            """)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        return context
    }()

    init(locale: Locale) {
        self.locale = locale
    }

    public func itemRandomOptionName(forItemRandomOptionID itemRandomOptionID: Int) -> String? {
        guard let result = try? context.call("itemRandomOptionName", with: [itemRandomOptionID]) as? String else {
            return nil
        }

        let itemRandomOptionName = result.transcoding(from: .isoLatin1, to: .koreanEUC)
        return itemRandomOptionName
    }
}
