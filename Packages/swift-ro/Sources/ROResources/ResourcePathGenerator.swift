//
//  ResourcePathGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/8.
//

import ROCore

final public class ResourcePathGenerator: Sendable {
    package let scriptManager: ScriptManager

    public init(scriptManager: ScriptManager) {
        self.scriptManager = scriptManager
    }

    public func generateItemSpritePath(itemID: Int) -> ResourcePath? {
        guard let resourceName = scriptManager.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.spriteDirectory.appending([K2L("아이템"), "\(resourceName)"])
    }

    public func generateSkillSpritePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.spriteDirectory.appending([K2L("아이템"), "\(skillAegisName)"])
    }

    public func generateItemIconImagePath(itemID: Int) -> ResourcePath? {
        guard let resourceName = scriptManager.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.userInterfaceDirectory.appending(["item", "\(resourceName).bmp"])
    }

    public func generateItemPreviewImagePath(itemID: Int) -> ResourcePath? {
        guard let resourceName = scriptManager.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.userInterfaceDirectory.appending(["collection", "\(resourceName).bmp"])
    }

    public func generateSkillIconImagePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["item", "\(skillAegisName).bmp"])
    }

    public func generateMapImagePath(mapName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["map", "\(mapName).bmp"])
    }

    public func generateStatusIconImagePath(statusID: Int) -> ResourcePath? {
        guard let iconName = scriptManager.statusIconName(forStatusID: statusID) else {
            return nil
        }

        return ResourcePath.effectDirectory.appending(iconName)
    }
}
