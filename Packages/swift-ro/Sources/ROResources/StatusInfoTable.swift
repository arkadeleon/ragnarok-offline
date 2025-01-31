//
//  StatusInfoTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/1/29.
//

@preconcurrency import Lua

public actor StatusInfoTable {
    public static let shared = StatusInfoTable(locale: .current)

    let locale: Locale

    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "efstids", withExtension: "lub", locale: .korean) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "stateiconimginfo", withExtension: "lub", locale: .korean) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "stateiconinfo", withExtension: "lub", locale: .korean) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            try context.parse("""
            function statusIconName(statusID)
                local gold = StateIconImgList[PRIORITY_GOLD][statusID]
                local red = StateIconImgList[PRIORITY_RED][statusID]
                local blue = StateIconImgList[PRIORITY_BLUE][statusID]
                local green = StateIconImgList[PRIORITY_GREEN][statusID]
                local white = StateIconImgList[PRIORITY_WHITE][statusID]
                if gold ~= nil then
                    return gold
                elseif red ~= nil then
                    return red
                elseif blue ~= nil then
                    return blue
                elseif green ~= nil then
                    return green
                elseif white ~= nil then
                    return white
                else
                    return nil
                end
            end
            function statusDescription(statusID)
                return StateIconList[statusID]["descript"][1][1]
            end
            """)
        } catch {
            print(error)
        }

        return context
    }()

    init(locale: Locale) {
        self.locale = locale
    }

    public func iconName(forStatusID statusID: Int) -> String? {
        guard let result = try? context.call("statusIconName", with: [statusID]) as? String else {
            return nil
        }

        let iconName = result.transcoding(from: .isoLatin1, to: .koreanEUC)
        return iconName
    }

    public func localizedDescription(forStatusID statusID: Int) -> String? {
        guard let result = try? context.call("statusDescription", with: [statusID]) as? String else {
            return nil
        }

        let localizedDescription = result.transcoding(from: .isoLatin1, to: .koreanEUC)
        return localizedDescription
    }
}
