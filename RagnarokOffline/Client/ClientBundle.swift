//
//  ClientBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation

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
        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\collection\\\(resourceName).bmp")
        return path
    }

    func monsterSpritePath(forResourceName resourceName: String) -> (spr: GRF.Path, act: GRF.Path) {
        let sprPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).act")
        return (spr: sprPath, act: actPath)
    }

    func bodySpritePath(forSexID sexID: Int, jobID: Int) -> (spr: GRF.Path, act: GRF.Path) {
        let sexResourceName = SexID(rawValue: sexID).resourceName
        let jobResourceName = JobID(rawValue: jobID).resourceName

        let sprPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(sexResourceName)\\\(jobResourceName)_\(sexResourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(sexResourceName)\\\(jobResourceName)_\(sexResourceName).act")
        return (spr: sprPath, act: actPath)
    }

    func skillSpritePath(forResourceName resourceName: String) -> (spr: GRF.Path, act: GRF.Path) {
        let sprPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).act")
        return (spr: sprPath, act: actPath)
    }
}
