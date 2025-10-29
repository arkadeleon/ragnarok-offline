//
//  File+Icon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

extension File {
    var iconName: String {
        switch utType {
        case let utType where utType.conforms(to: .directory):
            "folder.fill"
        case let utType where utType.conforms(to: .archive):
            "doc.zipper"
        case let utType where utType.conforms(to: .text):
            "doc.text"
        case .lua, .lub:
            "doc.text"
        case let utType where utType.conforms(to: .image):
            "photo"
        case .ebm, .pal:
            "photo"
        case let utType where utType.conforms(to: .audio):
            "waveform.circle"
        case .act:
            "livephoto"
        case .gat:
            "square.grid.3x3.middle.filled"
        case .gnd:
            "mountain.2"
        case .imf:
            "square.stack.3d.up"
        case .rsm:
            "cube"
        case .rsw:
            "map"
        case .spr:
            "photo.stack"
        case .str:
            "sparkles.rectangle.stack"
        default:
            "doc"
        }
    }
}
