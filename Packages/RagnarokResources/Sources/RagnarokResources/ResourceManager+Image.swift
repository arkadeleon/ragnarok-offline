//
//  ResourceManager+Image.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/9/16.
//

import ImageIO

enum ImageResourceError: Error {
    case cannotCreateImage
}

extension ResourceManager {
    public func image(at path: ResourcePath) async throws -> CGImage {
        let data = try await contentsOfResource(at: path)

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageResourceError.cannotCreateImage
        }

        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw ImageResourceError.cannotCreateImage
        }

        return image
    }
}
