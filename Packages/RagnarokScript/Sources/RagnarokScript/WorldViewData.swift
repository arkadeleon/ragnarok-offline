//
//  WorldViewData.swift
//  RagnarokScript
//
//  Created by Leon Li on 2026/8/30.
//

import RagnarokResources

final public class WorldViewData: Resource {
    public let worlds: [WorldViewData.World]

    init(worlds: [WorldViewData.World] = []) {
        self.worlds = worlds
    }
}

extension WorldViewData {

    /// Where something is drawn, in pixels of the 1280x1024 world map image.
    public struct Rect: Equatable, Sendable {
        public var left: Int
        public var top: Int
        public var right: Int
        public var bottom: Int
    }

    public struct World: Sendable {
        public var name: String
        public var imageName: String
        public var maps: [WorldViewData.Map]
        public var dungeons: [WorldViewData.Dungeon]
    }

    public struct Map: Sendable {

        /// Maps sharing a group index belong to the dungeon with that index.
        /// Group indices from 100 up have no dungeon and stand on their own.
        public var groupIndex: Int

        /// The map name with the rsw extension, such as `tha_t01.rsw`.
        public var mapName: String

        public var rect: WorldViewData.Rect

        public var name: String

        /// The monster level, such as `110`. Empty for towns.
        public var monsterLevel: String
    }

    public struct Dungeon: Sendable {

        public var groupIndex: Int

        public var rect: WorldViewData.Rect

        public var name: String

        /// The monster level range, such as `110~130`.
        public var monsterLevel: String
    }
}

extension ResourceManager {
    public func worldViewData() async -> WorldViewData {
        await cachedResource(forIdentifier: "WorldViewData") { [self] in
            let loader = WorldViewDataLoader()
            return await loader.worldViewData(using: self)
        }
    }
}
