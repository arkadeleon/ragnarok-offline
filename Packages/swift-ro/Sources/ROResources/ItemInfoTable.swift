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
    public static let shared = ItemInfoTable(locale: .current)

    let locale: Locale
    let context: LuaContext?
    let identifiedNameTable: [Int : Data]
    let identifiedDescriptionTable: [Int : Data]

    init(locale: Locale) {
        self.locale = locale

        if let url = Bundle.module.url(forResource: "itemInfo", withExtension: "lub", locale: locale) {
            context = {
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

                return context
            }()

            identifiedNameTable = [:]
            identifiedDescriptionTable = [:]
        } else {
            context = nil

            identifiedNameTable = {
                guard let url = Bundle.module.url(forResource: "idnum2itemdisplaynametable", withExtension: "txt", locale: locale),
                      let stream = try? FileStream(url: url) else {
                    return [:]
                }

                let reader = StreamReader(stream: stream, delimiter: "\r\n")
                defer {
                    reader.close()
                }

                var nameTable: [Int : Data] = [:]

                while let line = reader.readLine() {
                    if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                        continue
                    }

                    let columns = line.split(separator: "#")
                    if columns.count >= 2 {
                        let itemID = Int(columns[0])
                        let itemDisplayName = columns[1]
                        if let itemID {
                            nameTable[itemID] = itemDisplayName.data(using: .isoLatin1)
                        }
                    }
                }

                return nameTable
            }()

            identifiedDescriptionTable = {
                guard let url = Bundle.module.url(forResource: "idnum2itemdesctable", withExtension: "txt", locale: locale),
                      let stream = try? FileStream(url: url) else {
                    return [:]
                }

                let reader = StreamReader(stream: stream, delimiter: "\r\n#\r\n")
                defer {
                    reader.close()
                }

                var descriptionTable: [Int : Data] = [:]

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
                            descriptionTable[itemID] = itemDescription.data(using: .isoLatin1)
                        }
                    }
                }

                return descriptionTable
            }()
        }
    }

    public func localizedIdentifiedItemName(forItemID itemID: Int) -> String? {
        if let context {
            guard let result = try? context.call("identifiedItemDisplayName", with: [itemID]) as? String else {
                return nil
            }

            let encoding = locale.language.preferredEncoding
            let itemName = result.transcoding(from: .isoLatin1, to: encoding)
            return itemName
        } else {
            let encoding = locale.language.preferredEncoding
            let itemName = identifiedNameTable[itemID]
                .flatMap({ String(data: $0, encoding: encoding) })
            return itemName
        }
    }

    public func localizedIdentifiedItemDescription(forItemID itemID: Int) -> String? {
        if let context {
            guard let result = try? context.call("identifiedItemDescription", with: [itemID]) as? [String] else {
                return nil
            }

            let encoding = locale.language.preferredEncoding
            let itemDescription = result.joined(separator: "\n").transcoding(from: .isoLatin1, to: encoding)
            return itemDescription
        } else {
            let encoding = locale.language.preferredEncoding
            let itemDescription = identifiedDescriptionTable[itemID]
                .flatMap({ String(data: $0, encoding: encoding) })
            return itemDescription
        }
    }
}
