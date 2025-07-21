//
//  File+DevelopmentPreview.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import Foundation
import GRF
import ROCore
import ROResources

extension File {
    static func previewGRF() -> File {
        let url = ResourceManager.shared.localURL.appending(path: "data.grf")
        let grfArchive = GRFArchive(url: url)
        let file = File(node: .grfArchive(grfArchive))
        return file
    }

    static func previewACT() async throws -> File {
        let locator = try await ResourceManager.shared.locatorOfResource(at: ["data", "sprite", "cursors.act"])
        let file = File(locator)
        return file
    }

    static func previewGAT() async throws -> File {
        let locator = try await ResourceManager.shared.locatorOfResource(at: ["data", "iz_int.gat"])
        let file = File(locator)
        return file
    }

    static func previewGND() async throws -> File {
        let locator = try await ResourceManager.shared.locatorOfResource(at: ["data", "iz_int.gnd"])
        let file = File(locator)
        return file
    }

    static func previewRSM() async throws -> File {
        let locator = try await ResourceManager.shared.locatorOfResource(at: ["data", "model", K2L("내부소품"), K2L("철다리.rsm")])
        let file = File(locator)
        return file
    }

    static func previewRSW() async throws -> File {
        let locator = try await ResourceManager.shared.locatorOfResource(at: ["data", "iz_int.rsw"])
        let file = File(locator)
        return file
    }

    static func previewSPR() async throws -> File {
        let locator = try await ResourceManager.shared.locatorOfResource(at: ["data", "sprite", "cursors.spr"])
        let file = File(locator)
        return file
    }
}
