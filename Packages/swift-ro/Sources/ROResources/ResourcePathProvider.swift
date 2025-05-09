//
//  ResourcePathProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/8.
//

final public class ResourcePathProvider: Sendable {
    package let scriptManager: ScriptManager

    public init(scriptManager: ScriptManager) {
        self.scriptManager = scriptManager
    }

    public func itemSpritePath(itemID: Int) async -> ResourcePath? {
        guard let resourceName = await scriptManager.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.spriteDirectory.appending(["아이템", "\(resourceName)"])
    }

    public func skillSpritePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.spriteDirectory.appending(["아이템", "\(skillAegisName)"])
    }

    public func itemIconImagePath(itemID: Int) async -> ResourcePath? {
        guard let resourceName = await scriptManager.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.userInterfaceDirectory.appending(["item", "\(resourceName).bmp"])
    }

    public func itemPreviewImagePath(itemID: Int) async -> ResourcePath? {
        guard let resourceName = await scriptManager.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        return ResourcePath.userInterfaceDirectory.appending(["collection", "\(resourceName).bmp"])
    }

    public func skillIconImagePath(skillAegisName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["item", "\(skillAegisName).bmp"])
    }

    public func mapImagePath(mapName: String) -> ResourcePath {
        ResourcePath.userInterfaceDirectory.appending(["map", "\(mapName).bmp"])
    }

    public func statusIconImagePath(statusID: Int) async -> ResourcePath? {
        guard let iconName = await StatusInfoTable.current.iconName(forStatusID: statusID) else {
            return nil
        }

        return ResourcePath.effectDirectory.appending(iconName)
    }
}
