//
//  GAT+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/15.
//

import RagnarokFileFormats

extension GAT {
    var json: String {
        """
        {
          "header": \(header.quoted),
          "version": \(version),
          "width": \(width),
          "height": \(height),
          "tiles": \(tiles.map(\.json).json)
        }
        """
    }
}

extension GAT.Tile {
    var json: String {
        """
        {
          "bottomLeftAltitude": \(bottomLeftAltitude),
          "bottomRightAltitude": \(bottomRightAltitude),
          "topLeftAltitude": \(topLeftAltitude),
          "topRightAltitude": \(topRightAltitude),
          "type": \(type.rawValue)
        }
        """
    }
}
