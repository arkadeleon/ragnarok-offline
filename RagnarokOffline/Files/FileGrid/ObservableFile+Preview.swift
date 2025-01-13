//
//  ObservableFile+Preview.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import Foundation

extension ObservableFile {
    static var previewDataDirectory: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data")
        let file = ObservableFile(file: .directory(url))
        return file
    }

    static var previewACT: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/sprite/cursors.act")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var previewGAT: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/06guild_r.gat")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var previewGND: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/06guild_r.gnd")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var previewRSM: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/model/내부소품/철다리.rsm")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var previewRSW: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/06guild_r.rsw")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var previewSPR: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/sprite/cursors.spr")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }
}
