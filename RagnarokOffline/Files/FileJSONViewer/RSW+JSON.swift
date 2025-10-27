//
//  RSW+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/16.
//

import RagnarokFileFormats

extension RSW {
    var json: String {
        """
        {
          "header": \(header.quoted),
          "version": \(version),
          "files": \(files.json),
          "water": \(water.json),
          "light": \(light.json),
          "boundingBox": \(boundingBox.json),
          "models": \(models.map(\.json).json),
          "lights": \(lights.map(\.json).json),
          "sounds": \(sounds.map(\.json).json),
          "effects": \(effects.map(\.json).json)
        }
        """
    }
}

extension RSW.Files {
    var json: String {
        """
        {
          "ini": \(ini.quoted),
          "gnd": \(gnd.quoted),
          "gat": \(gat.quoted),
          "src": \(src.quoted)
        }
        """
    }
}

extension RSW.Water {
    var json: String {
        """
        {
          "level": \(level),
          "type": \(type),
          "waveHeight": \(waveHeight),
          "waveSpeed": \(waveSpeed),
          "wavePitch": \(wavePitch),
          "animSpeed": \(animSpeed)
        }
        """
    }
}

extension RSW.Light {
    var json: String {
        """
        {
          "longitude": \(longitude),
          "latitude": \(latitude),
          "diffuseRed": \(diffuseRed),
          "diffuseGreen": \(diffuseGreen),
          "diffuseBlue": \(diffuseBlue),
          "ambientRed": \(ambientRed),
          "ambientGreen": \(ambientGreen),
          "ambientBlue": \(ambientBlue),
          "opacity": \(opacity)
        }
        """
    }
}

extension RSW.BoundingBox {
    var json: String {
        """
        {
          "top": \(top),
          "bottom": \(bottom),
          "left": \(left),
          "right": \(right)
        }
        """
    }
}

extension RSW.Objects.Model {
    var json: String {
        """
        {
          "name": \(name.quoted),
          "animationType": \(animationType),
          "animationSpeed": \(animationSpeed),
          "blockType": \(blockType),
          "modelName": \(modelName.quoted),
          "nodeName": \(nodeName.quoted),
          "position": \(position.json),
          "rotation": \(rotation.json),
          "scale": \(scale.json)
        }
        """
    }
}

extension RSW.Objects.Light {
    var json: String {
        """
        {
          "name": \(name.quoted),
          "position": \(position.json),
          "diffuseRed": \(diffuseRed),
          "diffuseGreen": \(diffuseGreen),
          "diffuseBlue": \(diffuseBlue),
          "range": \(range)
        }
        """
    }
}

extension RSW.Objects.Sound {
    var json: String {
        """
        {
          "name": \(name.quoted),
          "waveName": \(waveName.quoted),
          "position": \(position.json),
          "volume": \(volume),
          "width": \(width),
          "height": \(height),
          "range": \(range),
          "cycle": \(cycle)
        }
        """
    }
}

extension RSW.Objects.Effect {
    var json: String {
        """
        {
          "name": \(name.quoted),
          "position": \(position.json),
          "id": \(id),
          "delay": \(delay),
          "parameters": \(parameters.json)
        }
        """
    }
}
