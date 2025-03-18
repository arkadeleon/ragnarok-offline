//
//  File+Icon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

extension File {
    var iconName: String {
        guard let utType else {
            return "doc"
        }

        switch utType {
        case let utType where utType.conforms(to: .directory):
            return "folder.fill"
        case let utType where utType.conforms(to: .archive):
            return "doc.zipper"
        case let utType where utType.conforms(to: .text):
            return "doc.text"
        case .lua, .lub:
            return "doc.text"
        case let utType where utType.conforms(to: .image):
            return "photo"
        case .ebm, .pal:
            return "photo"
        case let utType where utType.conforms(to: .audio):
            return "waveform.circle"
        case .act:
            return "livephoto"
        case .gat:
            return "square.grid.3x3.middle.filled"
        case .gnd:
            return "mountain.2"
        case .imf:
            return "square.stack.3d.up"
        case .rsm:
            return "cube"
        case .rsw:
            return "map"
        case .spr:
            return "photo.stack"
        case .str:
            return "sparkles.rectangle.stack"
        default:
            return "doc"
        }
    }
}
