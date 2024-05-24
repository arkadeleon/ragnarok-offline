//
//  File+UTType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/19.
//

import UniformTypeIdentifiers

extension File {
    public var utType: UTType? {
        if case .directory = self {
            return .folder
        }

        if case .grfDirectory = self {
            return .directory
        }

        switch (name as NSString).pathExtension.lowercased() {
        case "act":
            return .act
        case "bmp":
            return .bmp
        case "ebm":
            return .ebm
        case "gat":
            return .gat
        case "gnd":
            return .gnd
        case "grf":
            return .grf
        case "ini":
            return .text
        case "jpg", "jpeg":
            return .jpeg
        case "lua":
            return .lua
        case "lub":
            return .lub
        case "mp3":
            return .mp3
        case "pal":
            return .pal
        case "png":
            return .png
        case "rsm":
            return .rsm
        case "rsw":
            return .rsw
        case "spr":
            return .spr
        case "str":
            return .str
        case "tga":
            return .image
        case "txt":
            return .text
        case "wav":
            return .wav
        case "xml":
            return .xml
        default:
            return nil
        }
    }

    public var isDirectory: Bool {
        if let utType, utType.conforms(to: .directory) {
            true
        } else {
            false
        }
    }

    public var isArchive: Bool {
        if let utType, utType.conforms(to: .archive) {
            true
        } else {
            false
        }
    }
}

extension UTType {
    public static let lua = UTType(importedAs: "public.x-lua")
    public static let lub = UTType(importedAs: "public.x-lua-bytecode")

    public static let grf = UTType(exportedAs: "kr.co.gravity.grf")
    public static let act = UTType(exportedAs: "kr.co.gravity.act")
    public static let ebm = UTType(exportedAs: "kr.co.gravity.ebm")
    public static let gat = UTType(exportedAs: "kr.co.gravity.gat")
    public static let gnd = UTType(exportedAs: "kr.co.gravity.gnd")
    public static let pal = UTType(exportedAs: "kr.co.gravity.pal")
    public static let rsm = UTType(exportedAs: "kr.co.gravity.rsm")
    public static let rsw = UTType(exportedAs: "kr.co.gravity.rsw")
    public static let spr = UTType(exportedAs: "kr.co.gravity.spr")
    public static let str = UTType(exportedAs: "kr.co.gravity.str")
}
