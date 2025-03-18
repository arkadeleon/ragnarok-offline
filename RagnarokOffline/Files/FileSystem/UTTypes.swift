//
//  UTTypes.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/19.
//

import UniformTypeIdentifiers

extension UTType {
    static let lua = UTType(importedAs: "public.x-lua")
    static let lub = UTType(importedAs: "public.x-lua-bytecode")

    static let grf = UTType(exportedAs: "kr.co.gravity.grf")
    static let act = UTType(exportedAs: "kr.co.gravity.act")
    static let ebm = UTType(exportedAs: "kr.co.gravity.ebm")
    static let gat = UTType(exportedAs: "kr.co.gravity.gat")
    static let gnd = UTType(exportedAs: "kr.co.gravity.gnd")
    static let imf = UTType(exportedAs: "kr.co.gravity.imf")
    static let pal = UTType(exportedAs: "kr.co.gravity.pal")
    static let rsm = UTType(exportedAs: "kr.co.gravity.rsm")
    static let rsw = UTType(exportedAs: "kr.co.gravity.rsw")
    static let spr = UTType(exportedAs: "kr.co.gravity.spr")
    static let str = UTType(exportedAs: "kr.co.gravity.str")
}
