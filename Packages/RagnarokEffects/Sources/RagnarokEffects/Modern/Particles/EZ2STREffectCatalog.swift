//
//  EZ2STREffectCatalog.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/22.
//

import Foundation
import RagnarokCore
import RagnarokFileFormats
import RagnarokResources

/// Data-driven catalog of `EZ2STREffect.bson` entries (`ID >= 10000`),
/// ported from `CEZ2STREffectMgr` in `EffectResourceSwitcher.cpp`
/// and `JsonCppLoader::GetEZ2STREffect` in `FileCreation.cpp`.
public struct EZ2STREffectCatalog: Sendable, Equatable {
    public static let baseEffectID: Int = 10000
    public static let resourcePath = ResourcePath(components: ["data", "ContentData", "EffectData", "EZ2STREffect.bson"])

    public struct Entry: Sendable, Equatable {
        public let id: Int
        public let key: String
        public let displayName: String
        public let filePath: String
        public let offsetX: Float
        public let offsetY: Float
        public let isInfinite: Bool
        public let isFloor: Bool
        public let isAboveUI: Bool
        public let soundPath: String
        public let isSoundLoop: Bool
        public let quakeDelay: Int
        public let startDelayTime: Int
        public let isToGround: Bool

        public var rawEffectID: Int {
            EZ2STREffectCatalog.baseEffectID + id
        }

        public init(
            id: Int,
            key: String,
            displayName: String? = nil,
            filePath: String,
            offsetX: Float = 0,
            offsetY: Float = 0,
            isInfinite: Bool = false,
            isFloor: Bool = false,
            isAboveUI: Bool = false,
            soundPath: String = "",
            isSoundLoop: Bool = false,
            quakeDelay: Int = -1,
            startDelayTime: Int = 0,
            isToGround: Bool = false
        ) {
            self.id = id
            self.key = key.lowercased()
            self.displayName = displayName ?? key
            self.filePath = filePath
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.isInfinite = isInfinite
            self.isFloor = isFloor
            self.isAboveUI = isAboveUI
            self.soundPath = soundPath
            self.isSoundLoop = isSoundLoop
            self.quakeDelay = quakeDelay
            self.startDelayTime = startDelayTime
            self.isToGround = isToGround
        }
    }

    public let entries: [EZ2STREffectCatalog.Entry]
    private let entriesByRawID: [Int : EZ2STREffectCatalog.Entry]
    private let entriesByKey: [String : EZ2STREffectCatalog.Entry]

    public init(entries: [EZ2STREffectCatalog.Entry] = []) {
        self.entries = entries
        self.entriesByRawID = Dictionary(uniqueKeysWithValues: entries.map { ($0.rawEffectID, $0) })
        self.entriesByKey = Dictionary(uniqueKeysWithValues: entries.map { ($0.key, $0) })
    }

    public init(data: Data) throws {
        let bson = try BSON(data: data)
        self.init(bson: bson)
    }

    public init(bson: BSON) {
        guard let table = bson.root["EZ2STREffect"]?.documentValue else {
            self.init(entries: [])
            return
        }

        // Entries are ordered lexicographically by UTF-8 key and assigned sequential IDs starting at 0,
        // skipping entries with an empty `FilePath`.
        let sortedRecords = table.sorted { $0.key < $1.key }
        var entries: [EZ2STREffectCatalog.Entry] = []
        var seenKeys: Set<String> = []
        entries.reserveCapacity(sortedRecords.count)

        for (rawKey, rawValue) in sortedRecords {
            guard let node = rawValue.documentValue,
                  let rawFilePath = node["FilePath"]?.stringValue,
                  !rawFilePath.isEmpty else {
                continue
            }

            let normalizedKey = K2L(rawKey).lowercased()
            guard seenKeys.insert(normalizedKey).inserted else {
                continue
            }

            let entry = EZ2STREffectCatalog.Entry(
                id: entries.count,
                key: normalizedKey,
                displayName: rawKey,
                filePath: K2L(rawFilePath),
                offsetX: Float(node["PosX"]?.doubleValue ?? 0),
                offsetY: Float(node["PosY"]?.doubleValue ?? 0),
                isInfinite: node["IsInfinite"]?.boolValue ?? false,
                isFloor: node["IsFloor"]?.boolValue ?? false,
                isAboveUI: node["IsAboveUI"]?.boolValue ?? false,
                soundPath: K2L(node["SoundPath"]?.stringValue ?? ""),
                isSoundLoop: node["IsSoundLoop"]?.boolValue ?? false,
                quakeDelay: node["QuakeDelay"]?.intValue ?? -1,
                startDelayTime: node["StartDelayTime"]?.intValue ?? 0,
                isToGround: node["IsToGround"]?.boolValue ?? false
            )
            entries.append(entry)
        }

        self.init(entries: entries)
    }

    public var rawEffectIDs: [Int] {
        entries.map(\.rawEffectID)
    }

    public func entry(forRawEffectID rawEffectID: Int) -> EZ2STREffectCatalog.Entry? {
        entriesByRawID[rawEffectID]
    }

    public func entry(named name: String) -> EZ2STREffectCatalog.Entry? {
        entriesByKey[K2L(name).lowercased()]
    }

    public func rawEffectID(named name: String) -> Int? {
        entry(named: name)?.rawEffectID
    }

    public static func load(from resourceManager: ResourceManager) async -> EZ2STREffectCatalog? {
        guard !Task.isCancelled,
              let data = try? await resourceManager.contentsOfResource(at: resourcePath),
              !Task.isCancelled,
              let catalog = try? EZ2STREffectCatalog(data: data) else {
            return nil
        }
        return catalog
    }
}
