//
//  ResourcePath+CommonPaths.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/9/26.
//

import RagnarokCore

extension ResourcePath {
    public static let scriptDirectory: ResourcePath = ["data", "luafiles514", "lua files"]
    public static let modelDirectory: ResourcePath = ["data", "model"]
    public static let paletteDirectory: ResourcePath = ["data", "palette"]
    public static let spriteDirectory: ResourcePath = ["data", "sprite"]
    public static let textureDirectory: ResourcePath = ["data", "texture"]
    public static let effectDirectory: ResourcePath = ["data", "texture", "effect"]
    public static let userInterfaceDirectory: ResourcePath = ["data", "texture", K2L("유저인터페이스")]
}

extension ResourcePath {
    public static func generateItemSpritePath(itemResourceName: String) -> ResourcePath {
        ResourcePath.spriteDirectory.appending([K2L("아이템"), "\(itemResourceName)"])
    }

    public static func generateSkillSpritePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.spriteDirectory.appending([K2L("아이템"), "\(skillAegisName)"])
    }

    public static func generateItemIconImagePath(itemResourceName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["item", "\(itemResourceName).bmp"])
    }

    public static func generateItemPreviewImagePath(itemResourceName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["collection", "\(itemResourceName).bmp"])
    }

    public static func generateSkillIconImagePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["item", "\(skillAegisName).bmp"])
    }

    public static func generateMapImagePath(mapName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["map", "\(mapName).bmp"])
    }
}
