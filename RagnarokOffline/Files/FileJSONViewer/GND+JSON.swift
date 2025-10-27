//
//  GND+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/16.
//

import RagnarokFileFormats

extension GND {
    var json: String {
        """
        {
          "header": \(header.quoted),
          "version": \(version),
          "width": \(width),
          "height": \(height),
          "zoom": \(zoom),
          "textures": \(textures.map(\.quoted).json),
          "lightmap": \(lightmap.count),
          "surfaces": \(surfaces.map(\.json).json),
          "cubes": \(cubes.map(\.json).json)
        }
        """
    }
}

extension GND.Surface {
    var json: String {
        """
        {
          "u": \(u.json),
          "v": \(v.json),
          "textureIndex": \(textureIndex),
          "lightmapIndex": \(lightmapIndex),
          "color": \(color.json)
        }
        """
    }
}

extension GND.Cube {
    var json: String {
        """
        {
          "bottomLeftAltitude": \(bottomLeftAltitude),
          "bottomRightAltitude": \(bottomRightAltitude),
          "topLeftAltitude": \(topLeftAltitude),
          "topRightAltitude": \(topRightAltitude),
          "topSurfaceIndex": \(topSurfaceIndex),
          "frontSurfaceIndex": \(frontSurfaceIndex),
          "rightSurfaceIndex": \(rightSurfaceIndex)
        }
        """
    }
}
