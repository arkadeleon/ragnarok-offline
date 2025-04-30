//
//  ImageResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/3.
//

import CoreGraphics
import ROCore
import ROResources

enum ImageResourceError: Error {
    case cannotCreateImage
}

extension ResourceManager {
    public func image(at path: ResourcePath, removesMagentaPixels: Bool = false) async throws -> CGImage {
        let data = try await contentsOfResource(at: path)

        var image = CGImageCreateWithData(data)
        if removesMagentaPixels {
            image = image?.removingMagentaPixels()
        }

        if let image {
            return image
        } else {
            throw ImageResourceError.cannotCreateImage
        }
    }
}

extension ResourcePath {
    public init?(itemIconImagePathWithItemID itemID: Int) async {
        guard let resourceName = await ScriptManager.default.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        self = ResourcePath.userInterfaceDirectory.appending(["item", "\(resourceName).bmp"])
    }

    public init?(itemPreviewImagePathWithItemID itemID: Int) async {
        guard let resourceName = await ScriptManager.default.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        self = ResourcePath.userInterfaceDirectory.appending(["collection", "\(resourceName).bmp"])
    }

    public init(skillIconImagePathWithSkillAegisName skillAegisName: String) {
        self = ResourcePath.userInterfaceDirectory.appending(["item", "\(skillAegisName).bmp"])
    }

    public init(mapImagePathWithMapName mapName: String) {
        self = ResourcePath.userInterfaceDirectory.appending(["map", "\(mapName).bmp"])
    }

    public init?(statusIconImagePathWithStatusID statusID: Int) async {
        guard let iconName = await StatusInfoTable.current.iconName(forStatusID: statusID) else {
            return nil
        }

        self = ResourcePath.effectDirectory.appending(iconName)
    }
}
