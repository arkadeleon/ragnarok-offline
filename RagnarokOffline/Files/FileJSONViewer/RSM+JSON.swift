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
          "transformMatrix": \(transformMatrix.debugDescription.quoted),
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
          "vertexIndices": \(vertexIndices.json),
          "tvertexIndices": \(tvertexIndices.json),
          "textureIndex": \(textureIndex),
          "padding": \(padding),
          "twoSided": \(twoSided),
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
          "scale": \(scale),
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
          "quaternion": \(quaternion.debugDescription.quoted)
        }
        """
    }
}

extension RSM.PositionKeyframe {
    var json: String {
        """
        {
          "frame": \(frame),
          "position": \(position),
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
