//
//  ClientBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation
import rAthenaDatabase

class ClientBundle {
    static let shared = ClientBundle()

    let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let grf: GRFWrapper

    init() {
        grf = GRFWrapper(url: url.appendingPathComponent("data.grf"))
    }

    func itemSpritePath(forResourceName resourceName: String) -> (spr: GRF.Path, act: GRF.Path) {
        let sprPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).act")
        return (spr: sprPath, act: actPath)
    }

    func itemUserInterfacePath(forResourceName resourceName: String) -> GRF.Path {
        let bmpPath = GRF.Path(string: "data\\texture\\유저인터페이스\\collection\\\(resourceName).bmp")
        return bmpPath
    }

    func monsterSpritePath(forResourceName resourceName: String) -> (spr: GRF.Path, act: GRF.Path) {
        let sprPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).act")
        return (spr: sprPath, act: actPath)
    }

    func bodySpritePath(forGender gender: Gender, job: Job) -> (spr: GRF.Path, act: GRF.Path) {
        let sprPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(gender.resourceName)\\\(job.resourceName)_\(gender.resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(gender.resourceName)\\\(job.resourceName)_\(gender.resourceName).act")
        return (spr: sprPath, act: actPath)
    }

    func headSpritePath(forGender gender: Gender, hairID: Int) -> (spr: GRF.Path, act: GRF.Path) {
        let sprPath = GRF.Path(string: "data\\sprite\\인간족\\머리통\\\(gender.resourceName)\\\(hairID)_\(gender.resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\인간족\\머리통\\\(gender.resourceName)\\\(hairID)_\(gender.resourceName).act")
        return (spr: sprPath, act: actPath)
    }

    func headPalettePath(forGender gender: Gender, hairID: Int, paletteID: Int) -> GRF.Path {
        let palPath = GRF.Path(string: "data\\palette\\머리\\머리\(hairID)_\(gender.resourceName)_\(paletteID).pal")
        return palPath
    }

    func skillSpritePath(forResourceName resourceName: String) -> (spr: GRF.Path, act: GRF.Path) {
        let sprPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).act")
        return (spr: sprPath, act: actPath)
    }
}
