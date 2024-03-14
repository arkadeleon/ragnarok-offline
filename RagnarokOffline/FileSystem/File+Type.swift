//
//  File+Type.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

extension File {
    var type: UTType? {
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

    var isDirectory: Bool {
        if let type, type.conforms(to: .directory) {
            true
        } else {
            false
        }
    }

    var isArchive: Bool {
        if let type, type.conforms(to: .archive) {
            true
        } else {
            false
        }
    }
}

extension File {
    var iconName: String {
        guard let type else {
            return "doc"
        }

        if type.conforms(to: .directory) {
            return "folder.fill"
        }

        if type.conforms(to: .archive) {
            return "doc.zipper"
        }

        switch type {
        case let type where type.conforms(to: .text) || type == .lua || type == .lub:
            return "doc.text"
        case let type where type.conforms(to: .image) || type == .ebm || type == .pal:
            return "photo"
        case let type where type.conforms(to: .audio):
            return "waveform.circle"
        case .act:
            return "livephoto"
        case .gat:
            return "square.grid.3x3.middle.filled"
        case .rsm:
            return "square.stack.3d.up"
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

extension UTType {
    static let grf = UTType(exportedAs: "kr.co.gravity.grf")
    static let act = UTType(exportedAs: "kr.co.gravity.act")
    static let ebm = UTType(exportedAs: "kr.co.gravity.ebm")
    static let gat = UTType(exportedAs: "kr.co.gravity.gat")
    static let gnd = UTType(exportedAs: "kr.co.gravity.gnd")
    static let pal = UTType(exportedAs: "kr.co.gravity.pal")
    static let rsm = UTType(exportedAs: "kr.co.gravity.rsm")
    static let rsw = UTType(exportedAs: "kr.co.gravity.rsw")
    static let spr = UTType(exportedAs: "kr.co.gravity.spr")
    static let str = UTType(exportedAs: "kr.co.gravity.str")

    static let lua = UTType(importedAs: "public.x-lua")
    static let lub = UTType(importedAs: "public.x-lua-bytecode")
}
