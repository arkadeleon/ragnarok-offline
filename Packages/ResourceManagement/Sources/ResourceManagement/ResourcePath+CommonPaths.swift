//
//  ResourcePath+CommonPaths.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/9/26.
//

import TextEncoding

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
    public static func generateItemSpritePath(itemID: Int, scriptContext: ScriptContext) -> ResourcePath? {
        guard let resourceName = scriptContext.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.spriteDirectory.appending([K2L("아이템"), "\(resourceName)"])
    }

    public static func generateSkillSpritePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.spriteDirectory.appending([K2L("아이템"), "\(skillAegisName)"])
    }

    public static func generateItemIconImagePath(itemID: Int, scriptContext: ScriptContext) -> ResourcePath? {
        guard let resourceName = scriptContext.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.userInterfaceDirectory.appending(["item", "\(resourceName).bmp"])
    }

    public static func generateItemPreviewImagePath(itemID: Int, scriptContext: ScriptContext) -> ResourcePath? {
        guard let resourceName = scriptContext.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.userInterfaceDirectory.appending(["collection", "\(resourceName).bmp"])
    }

    public static func generateSkillIconImagePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["item", "\(skillAegisName).bmp"])
    }

    public static func generateMapImagePath(mapName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["map", "\(mapName).bmp"])
    }

    public static func generateStatusIconImagePath(statusID: Int, scriptContext: ScriptContext) -> ResourcePath? {
        guard let iconName = scriptContext.statusIconName(forStatusID: statusID) else {
            return nil
        }

        return ResourcePath.effectDirectory.appending(iconName)
    }
}
