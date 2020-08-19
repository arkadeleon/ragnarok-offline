//
//  FileType.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/8/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

enum FileType: String {

    case txt
    case xml
    case ini
    case lua
    case lub
    case bmp
    case jpg
    case tga
    case pal
    case mp3
    case wav
    case spr
    case act
    case rsm
    case rsw
    case xxx

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "txt":
            self = .txt
        case "xml":
            self = .xml
        case "ini":
            self = .ini
        case "lua":
            self = .lua
        case "lub":
            self = .lub
        case "bmp":
            self = .bmp
        case "jpg", "jpeg":
            self = .jpg
        case "tga":
            self = .tga
        case "pal":
            self = .pal
        case "mp3":
            self = .mp3
        case "wav":
            self = .wav
        case "spr":
            self = .spr
        case "act":
            self = .act
        case "rsm":
            self = .rsm
        case "rsw":
            self = .rsw
        default:
            self = .xxx
        }
    }
}
