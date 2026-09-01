//
//  ImageResource.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/2/11.
//

import CoreGraphics
import RagnarokCore

enum ImageResourceError: Error {
    case cannotCreateImage
}

extension Resources {
    final public class Image: Resource {
        public let cgImage: CGImage

        init(cgImage: CGImage) {
            self.cgImage = cgImage
        }
    }
}

extension ResourceManager {
    public func image(at path: ResourcePath, removesMagentaPixels: Bool = false, thumbnailPixelSize: CGSize? = nil) async throws -> Resources.Image {
        let thumbnailPixelSizeString = thumbnailPixelSize.map({ "\($0.width)x\($0.height)" }) ?? "original"
        let resourceIdentifier = "\(path)?removesMagentaPixels=\(removesMagentaPixels)&thumbnailPixelSize=\(thumbnailPixelSizeString)"
        return try await imageResourceCache.resource(forIdentifier: resourceIdentifier) { [self] in
            let data = try await self.contentsOfResource(at: path)

            guard var cgImage = CGImageCreateWithData(data) else {
                throw ImageResourceError.cannotCreateImage
            }

            if removesMagentaPixels {
                cgImage = cgImage.removingMagentaPixels() ?? cgImage
            }

            if let thumbnailPixelSize,
               CGFloat(cgImage.width) > thumbnailPixelSize.width || CGFloat(cgImage.height) > thumbnailPixelSize.height {
                cgImage = cgImage.resizing(thumbnailPixelSize) ?? cgImage
            }

            return Resources.Image(cgImage: cgImage)
        }
    }
}

extension ResourceManager {
    public func itemIconImage(forItemID itemID: Int) async throws -> Resources.Image {
        let itemCommonInfoTable = await itemCommonInfoTable()
        guard let itemResourceName = itemCommonInfoTable.identifiedItemResourceName(forItemID: itemID) else {
            throw ResourceError.scriptContextIncomplete("identifiedItemResourceName")
        }
        let path = ResourcePath.generateItemIconImagePath(itemResourceName: itemResourceName)
        let image = try await image(at: path, removesMagentaPixels: true)
        return image
    }

    public func itemPreviewImage(forItemID itemID: Int) async throws -> Resources.Image {
        let itemCommonInfoTable = await itemCommonInfoTable()
        guard let itemResourceName = itemCommonInfoTable.identifiedItemResourceName(forItemID: itemID) else {
            throw ResourceError.scriptContextIncomplete("identifiedItemResourceName")
        }
        let path = ResourcePath.generateItemPreviewImagePath(itemResourceName: itemResourceName)
        let image = try await image(at: path, removesMagentaPixels: true)
        return image
    }

    public func mapImage(forMapName mapName: String, thumbnailPixelSize: CGSize? = nil) async throws -> Resources.Image {
        let path = ResourcePath.generateMapImagePath(mapName: mapName)
        let image = try await image(at: path, removesMagentaPixels: true, thumbnailPixelSize: thumbnailPixelSize)
        return image
    }

    public func statusIconImage(forStatusIconName statusIconName: String) async throws -> Resources.Image {
        let path = ResourcePath.effectDirectory.appending(statusIconName)
        let image = try await image(at: path)
        return image
    }
}
