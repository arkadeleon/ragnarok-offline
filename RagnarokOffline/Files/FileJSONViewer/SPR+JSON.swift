//
//  SPR+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/16.
//

import RagnarokFileFormats

extension SPR {
    var json: String {
        """
        {
          "header": \(header.quoted),
          "version": \(version),
          "sprites": \(sprites.map(\.json).json)
        }
        """
    }
}

extension SPR.Sprite {
    var json: String {
        """
        {
          "type": \(type.rawValue),
          "width": \(width),
          "height": \(height),
          "data": \(data.count)
        }
        """
    }
}
