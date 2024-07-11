//
//  PreviewFiles.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import Foundation

enum PreviewFiles {
    static var dataDirectory: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data")
        let file = ObservableFile(file: .directory(url))
        return file
    }

    static var actFile: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/sprite/cursors.act")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var gatFile: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/06guild_r.gat")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var gndFile: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/06guild_r.gnd")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var rmsFile: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/model/내부소품/철다리.rsm")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var rswFile: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/06guild_r.rsw")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }

    static var sprFile: ObservableFile {
        let url = Bundle.main.resourceURL!.appending(path: "data/sprite/cursors.spr")
        let file = ObservableFile(file: .regularFile(url))
        return file
    }
}
