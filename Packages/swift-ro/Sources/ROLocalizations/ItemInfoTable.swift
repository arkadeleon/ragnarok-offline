//
//  ItemInfoTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/28.
//

import Foundation
@preconcurrency import Lua
import ROCore

final public class ItemInfoTable: Sendable {
    enum LocalizationInfoDataSource {
        case lua(context: LuaContext)
        case txt(identifiedItemNamesByID: [Int : Data], identifiedItemDescriptionsByID: [Int : Data])
    }

    public static let shared = ItemInfoTable(locale: .current)

    let locale: Locale
    let resourceInfoContext: LuaContext
    let localizationInfoDataSource: LocalizationInfoDataSource

    init(locale: Locale) {
        self.locale = locale

        resourceInfoContext = {
            let context = LuaContext()

            do {
                if let url = Bundle.module.url(forResource: "itemInfo", withExtension: "lub", locale: .korean) {
                    let data = try Data(contentsOf: url)
                    try context.load(data)
                }

                try context.parse("""
                function unidentifiedItemResourceName(itemID)
                    return tbl[itemID]["unidentifiedResourceName"]
                end
                function identifiedItemResourceName(itemID)
                    return tbl[itemID]["identifiedResourceName"]
                end
                function itemSlotCount(itemID)
                    return tbl[itemID]["slotCount"]
                end
                """)
            } catch {
                print(error)
            }

            return context
        }()

        if let url = Bundle.module.url(forResource: "itemInfo", withExtension: "lub", locale: locale) {
            localizationInfoDataSource = {
                let context = LuaContext()

                do {
                    let data = try Data(contentsOf: url)
                    try context.load(data)

                    try context.parse("""
                    function unidentifiedItemDisplayName(itemID)
                        return tbl[itemID]["unidentifiedDisplayName"]
                    end
                    function unidentifiedItemDescription(itemID)
                        return tbl[itemID]["unidentifiedDescriptionName"]
                    end
                    function identifiedItemDisplayName(itemID)
                        return tbl[itemID]["identifiedDisplayName"]
                    end
                    function identifiedItemDescription(itemID)
                        return tbl[itemID]["identifiedDescriptionName"]
                    end
                    """)
                } catch {
                    print(error)
                }

                return .lua(context: context)
            }()
        } else {
            localizationInfoDataSource = {
                let identifiedItemNamesByID: [Int : Data] = {
                    guard let url = Bundle.module.url(forResource: "idnum2itemdisplaynametable", withExtension: "txt", locale: locale),
                          let stream = try? FileStream(url: url) else {
                        return [:]
                    }

                    let reader = StreamReader(stream: stream, delimiter: "\r\n")
                    defer {
                        reader.close()
                    }

                    var identifiedItemNamesByID: [Int : Data] = [:]

                    while let line = reader.readLine() {
                        if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                            continue
                        }

                        let columns = line.split(separator: "#")
                        if columns.count >= 2 {
                            let itemID = Int(columns[0])
                            let itemDisplayName = columns[1]
                            if let itemID {
                                identifiedItemNamesByID[itemID] = itemDisplayName.data(using: .isoLatin1)
                            }
                        }
                    }

                    return identifiedItemNamesByID
                }()

                let identifiedItemDescriptionsByID: [Int : Data] = {
                    guard let url = Bundle.module.url(forResource: "idnum2itemdesctable", withExtension: "txt", locale: locale),
                          let stream = try? FileStream(url: url) else {
                        return [:]
                    }

                    let reader = StreamReader(stream: stream, delimiter: "\r\n#\r\n")
                    defer {
                        reader.close()
                    }

                    var identifiedItemDescriptionsByID: [Int : Data] = [:]

                    while let line = reader.readLine() {
                        if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                            continue
                        }

                        let columns = line.split(separator: "#")
                        if columns.count >= 2 {
                            let itemID = Int(columns[0])
                            let itemDescription = columns[1]
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            if let itemID {
                                identifiedItemDescriptionsByID[itemID] = itemDescription.data(using: .isoLatin1)
                            }
                        }
                    }

                    return identifiedItemDescriptionsByID
                }()

                return .txt(
                    identifiedItemNamesByID: identifiedItemNamesByID,
                    identifiedItemDescriptionsByID: identifiedItemDescriptionsByID
                )
            }()
        }
    }

    public func identifiedItemResourceName(forItemID itemID: Int) -> String? {
        guard let result = try? resourceInfoContext.call("identifiedItemResourceName", with: [itemID]) as? String else {
            return nil
        }

        let encoding = Locale.korean.language.preferredEncoding
        let itemResourceName = result.transcoding(from: .isoLatin1, to: encoding)
        return itemResourceName
    }

    public func localizedIdentifiedItemName(forItemID itemID: Int) -> String? {
        switch localizationInfoDataSource {
        case .lua(let context):
            guard let result = try? context.call("identifiedItemDisplayName", with: [itemID]) as? String else {
                return nil
            }

            let encoding = locale.language.preferredEncoding
            let itemName = result.transcoding(from: .isoLatin1, to: encoding)
            return itemName
        case .txt(let identifiedItemNamesByID, _):
            let encoding = locale.language.preferredEncoding
            let itemName = identifiedItemNamesByID[itemID]
                .flatMap({ String(data: $0, encoding: encoding) })
            return itemName
        }
    }

    public func localizedIdentifiedItemDescription(forItemID itemID: Int) -> String? {
        switch localizationInfoDataSource {
        case .lua(let context):
            guard let result = try? context.call("identifiedItemDescription", with: [itemID]) as? [String] else {
                return nil
            }

            let encoding = locale.language.preferredEncoding
            let itemDescription = result.joined(separator: "\n").transcoding(from: .isoLatin1, to: encoding)
            return itemDescription
        case .txt(_, let identifiedItemDescriptionsByID):
            let encoding = locale.language.preferredEncoding
            let itemDescription = identifiedItemDescriptionsByID[itemID]
                .flatMap({ String(data: $0, encoding: encoding) })
            return itemDescription
        }
    }
}
