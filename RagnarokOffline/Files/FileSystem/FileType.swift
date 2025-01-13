//
//  FileType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

public enum FileType {
    case directory

    case text
    case image
    case audio

    case lua
    case lub

    case grf
    case act
    case ebm
    case gat
    case gnd
    case pal
    case rsm
    case rsw
    case spr
    case str

    case unknown

    init(_ extention: String) {
        switch extention.lowercased() {
        case "ini", "xml", "txt":
            self = .text
        case "bmp", "jpg", "jpeg", "png", "tga":
            self = .image
        case "mp3", "wav":
            self = .audio
        case "lua":
            self = .lua
        case "lub":
            self = .lub
        case "act":
            self = .act
        case "ebm":
            self = .ebm
        case "gat":
            self = .gat
        case "gnd":
            self = .gnd
        case "grf":
            self = .grf
        case "pal":
            self = .pal
        case "rsm":
            self = .rsm
        case "rsw":
            self = .rsw
        case "spr":
            self = .spr
        case "str":
            self = .str
        default:
            self = .unknown
        }
    }
}
