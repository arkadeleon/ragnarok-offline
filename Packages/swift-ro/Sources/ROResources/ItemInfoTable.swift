//
//  ItemInfoTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/28.
//

import BinaryIO
import Foundation
@preconcurrency import Lua
import Synchronization

final public class ItemInfoTable: Resource {
    enum ItemDataSource: ~Copyable {
        case lua(_ context: Mutex<LuaContext>)
        case txt(_ identifiedItemNamesByID: [Int : Data], _ identifiedItemDescriptionsByID: [Int : Data])
    }

    let locale: Locale
    let itemDataSource: ItemDataSource

    init(locale: Locale, context: LuaContext) {
        self.locale = locale
        self.itemDataSource = .lua(Mutex(context))
    }

    init(locale: Locale, identifiedItemNamesByID: [Int : Data], identifiedItemDescriptionsByID: [Int : Data]) {
        self.locale = locale
        self.itemDataSource = .txt(identifiedItemNamesByID, identifiedItemDescriptionsByID)
    }

    public func localizedIdentifiedItemName(forItemID itemID: Int) -> String? {
        switch itemDataSource {
        case .lua(let context):
            guard let result = context.withLock({ try? $0.call("identifiedItemDisplayName", with: [itemID]) as? String }) else {
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
        switch itemDataSource {
        case .lua(let context):
            guard let result = context.withLock({ try? $0.call("identifiedItemDescription", with: [itemID]) as? [String] }) else {
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

extension ResourceManager {
    public func itemInfoTable(for locale: Locale) async -> ItemInfoTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let taskIdentifier = "ItemInfoTable-\(localeIdentifier)"

        if let task = tasks.withLock({ $0[taskIdentifier] }) {
            return await task.value as! ItemInfoTable
        }

        let task = Task<any Resource, Never> {
            let itemInfoPath = ResourcePath(components: ["System", "itemInfo.lub"])
            if let itemInfoData = try? await contentsOfResource(at: itemInfoPath, locale: locale) {
                let context = LuaContext()

                do {
                    try context.load(itemInfoData)

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
                    logger.warning("\(error.localizedDescription)")
                }

                return ItemInfoTable(locale: locale, context: context)
            } else {
                let identifiedItemNamesByID: [Int : Data] = await {
                    let path = ResourcePath(components: ["data", "idnum2itemdisplaynametable.txt"])
                    guard let data = try? await contentsOfResource(at: path, locale: locale) else {
                        return [:]
                    }

                    let stream = MemoryStream(data: data)
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

                let identifiedItemDescriptionsByID: [Int : Data] = await {
                    let path = ResourcePath(components: ["data", "idnum2itemdesctable.txt"])
                    guard let data = try? await contentsOfResource(at: path, locale: locale) else {
                        return [:]
                    }

                    let stream = MemoryStream(data: data)
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

                return ItemInfoTable(
                    locale: locale,
                    identifiedItemNamesByID: identifiedItemNamesByID,
                    identifiedItemDescriptionsByID: identifiedItemDescriptionsByID
                )
            }
        }

        tasks.withLock {
            $0[taskIdentifier] = task
        }

        return await task.value as! ItemInfoTable
    }
}
