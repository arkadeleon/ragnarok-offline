//
//  STR+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/16.
//

import FileFormats

extension STR {
    var json: String {
        """
        {
          "header": \(header.quoted),
          "version": \(version),
          "fps": \(fps),
          "maxKeyframeIndex": \(maxKeyframeIndex),
          "layers": \(layers.map(\.json).json)
        }
        """
    }
}

extension STR.Layer {
    var json: String {
        """
        {
          "textures": \(textures.map(\.quoted).json),
          "keyframes": \(keyframes.map(\.json).json)
        }
        """
    }
}

extension STR.Keyframe {
    var json: String {
        """
        {
          "frameIndex": \(frameIndex),
          "type": \(type),
          "position": \(position.json),
          "uv": \(uv.json),
          "xy": \(xy.json),
          "textureIndex": \(textureIndex),
          "animationType": \(animationType),
          "delay": \(delay),
          "angle": \(angle),
          "color": \(color.json),
          "sourceAlpha": \(sourceAlpha),
          "destinationAlpha": \(destinationAlpha),
          "multiTexturePreset": \(multiTexturePreset)
        }
        """
    }
}
