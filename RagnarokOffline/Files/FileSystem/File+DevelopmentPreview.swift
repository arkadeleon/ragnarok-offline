//
//  File+DevelopmentPreview.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import Foundation

extension File {
    static var previewDataDirectory: File {
        let url = Bundle.main.resourceURL!.appending(path: "data")
        let file = File(node: .directory(url))
        return file
    }

    static var previewACT: File {
        let url = Bundle.main.resourceURL!.appending(path: "data/sprite/cursors.act")
        let file = File(node: .regularFile(url))
        return file
    }

    static var previewGAT: File {
        let url = Bundle.main.resourceURL!.appending(path: "data/iz_int.gat")
        let file = File(node: .regularFile(url))
        return file
    }

    static var previewGND: File {
        let url = Bundle.main.resourceURL!.appending(path: "data/iz_int.gnd")
        let file = File(node: .regularFile(url))
        return file
    }

    static var previewRSM: File {
        let url = Bundle.main.resourceURL!.appending(path: "data/model/내부소품/철다리.rsm")
        let file = File(node: .regularFile(url))
        return file
    }

    static var previewRSW: File {
        let url = Bundle.main.resourceURL!.appending(path: "data/iz_int.rsw")
        let file = File(node: .regularFile(url))
        return file
    }

    static var previewSPR: File {
        let url = Bundle.main.resourceURL!.appending(path: "data/sprite/cursors.spr")
        let file = File(node: .regularFile(url))
        return file
    }
}
