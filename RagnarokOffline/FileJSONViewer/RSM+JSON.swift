//
//  RSM+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/16.
//

import ROFileFormats

extension RSM {
    var json: String {
        """
        {
          "header": \(header.quoted),
          "version": \(version),
          "animationLength": \(animationLength),
          "shadeType": \(shadeType),
          "alpha": \(alpha),
          "textures": \(textures.map(\.quoted).json),
          "rootNodes": \(rootNodes.map(\.quoted).json),
          "nodes": \(nodes.map(\.json).json),
          "scaleKeyframes": \(scaleKeyframes.map(\.json).json),
          "volumeBoxes": \(volumeBoxes.map(\.json).json)
        }
        """
    }
}

extension RSM.Node {
    var json: String {
        """
        {
          "name": \(name.quoted),
          "parentName": \(parentName.quoted),
          "textures": \(textures.map(\.quoted).json),
          "textureIndexes": \(textureIndexes.json),
          "transformationMatrix": \(transformationMatrix.debugDescription.quoted),
          "offset": \(offset.json),
          "position": \(position.json),
          "rotationAngle": \(rotationAngle),
          "rotationAxis": \(rotationAxis.json),
          "scale": \(scale.json),
          "vertices": \(vertices.map(\.json).json),
          "tvertices": \(tvertices.map(\.json).json),
          "faces": \(faces.map(\.json).json),
          "scaleKeyframes": \(scaleKeyframes.map(\.json).json),
          "rotationKeyframes": \(rotationKeyframes.map(\.json).json),
          "positionKeyframes": \(positionKeyframes.map(\.json).json)
        }
        """
    }
}

extension RSM.Node.TextureVertex {
    var json: String {
        """
        {
          "color": \(color),
          "u": \(u),
          "v": \(v)
        }
        """
    }
}

extension RSM.Face {
    var json: String {
        """
        {
          "vertidx": \(vertidx.json),
          "tvertidx": \(tvertidx.json),
          "textureIndex": \(textureIndex),
          "padding": \(padding),
          "twoSide": \(twoSide),
          "smoothGroup": \(smoothGroup.json)
        }
        """
    }
}

extension RSM.ScaleKeyframe {
    var json: String {
        """
        {
          "frame": \(frame),
          "sx": \(sx),
          "sy": \(sy),
          "sz": \(sz),
          "data": \(data)
        }
        """
    }
}

extension RSM.RotationKeyframe {
    var json: String {
        """
        {
          "frame": \(frame),
          "quaternion": \(quaternion.json)
        }
        """
    }
}

extension RSM.PositionKeyframe {
    var json: String {
        """
        {
          "frame": \(frame),
          "px": \(px),
          "py": \(py),
          "pz": \(pz),
          "data": \(data)
        }
        """
    }
}

extension RSM.VolumeBox {
    var json: String {
        """
        {
          "size": \(size.json),
          "position": \(position.json),
          "rotation": \(rotation.json),
          "flag": \(flag)
        }
        """
    }
}
