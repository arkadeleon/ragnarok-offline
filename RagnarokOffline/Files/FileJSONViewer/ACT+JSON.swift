//
//  ACT+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/15.
//

import RagnarokFileFormats

extension ACT {
    var json: String {
        """
        {
          "header": \(header.quoted),
          "version": \(version),
          "actions": \(actions.map(\.json).json),
          "sounds": \(sounds.map(\.quoted).json)
        }
        """
    }
}

extension ACT.Action {
    var json: String {
        """
        {
          "frames": \(frames.map(\.json).json),
          "animationSpeed": \(animationSpeed)
        }
        """
    }
}

extension ACT.Frame {
    var json: String {
        """
        {
          "layers": \(layers.map(\.json).json),
          "soundIndex": \(soundIndex),
          "anchorPoints": \(anchorPoints.map(\.json).json)
        }
        """
    }
}

extension ACT.Layer {
    var json: String {
        """
        {
          "offset": \(offset.json),
          "spriteIndex": \(spriteIndex),
          "isMirrored": \(isMirrored),
          "color": \(color.json),
          "scale": \(scale.json),
          "rotationAngle": \(rotationAngle),
          "spriteType": \(spriteType),
          "width": \(width),
          "height": \(height)
        }
        """
    }
}

extension ACT.AnchorPoint {
    var json: String {
        """
        {
          "x": \(x),
          "y": \(y)
        }
        """
    }
}
