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
        guard let resourceName = await ItemInfoTable.current.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        self = .userInterface + ["item", "\(resourceName).bmp"]
    }

    public init?(itemPreviewImagePathWithItemID itemID: Int) async {
        guard let resourceName = await ItemInfoTable.current.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        self = .userInterface + ["collection", "\(resourceName).bmp"]
    }

    public init(skillIconImagePathWithSkillAegisName skillAegisName: String) {
        self = .userInterface + ["item", "\(skillAegisName).bmp"]
    }

    public init(mapImagePathWithMapName mapName: String) {
        self = .userInterface + ["map", "\(mapName).bmp"]
    }

    public init?(statusIconImagePathWithStatusID statusID: Int) async {
        guard let iconName = await StatusInfoTable.current.iconName(forStatusID: statusID) else {
            return nil
        }

        self = .effectPath + [iconName]
    }
}
