//
//  GameResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import CoreGraphics
import Foundation
import ROCore
import ROFileFormats
import ROGenerated
import ROResources

enum GameResourceError: Error {
    case resourceNotFound
}

public actor GameResourceManager {
    public static let `default` = GameResourceManager()

    public let baseURL: URL

    let grfs: [GRFReference]

    init() {
        baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        grfs = [
            GRFReference(url: baseURL.appending(path: "data.grf")),
        ]
    }

    // MARK: - data

    public func gat(forMapName mapName: String) async throws -> GAT {
        let path = GRF.Path(components: ["data", "\(mapName).gat"])
        let data = try contentsOfEntry(at: path)
        let gat = try GAT(data: data)
        return gat
    }

    public func gnd(forMapName mapName: String) async throws -> GND {
        let path = GRF.Path(components: ["data", "\(mapName).gnd"])
        let data = try contentsOfEntry(at: path)
        let gnd = try GND(data: data)
        return gnd
    }

    public func rsw(forMapName mapName: String) async throws -> RSW {
        let path = GRF.Path(components: ["data", "\(mapName).rsw"])
        let data = try contentsOfEntry(at: path)
        let rsw = try RSW(data: data)
        return rsw
    }

    // MARK: - data\model

    public func rsm(forModelName modelName: String) async throws -> RSM {
        let path = GRF.Path(components: ["data", "model", modelName])
        let data = try contentsOfEntry(at: path)
        let rsm = try RSM(data: data)
        return rsm
    }

    // MARK: - data\texture

    public func image(forTextureNamed textureName: String) async throws -> CGImage? {
        let path = GRF.Path(components: ["data", "texture", textureName])
        let data = try contentsOfEntry(at: path)
        let image = CGImageCreateWithData(data)
        return image
    }

    // MARK: - General

    public func contentsOfEntry(at path: GRF.Path) throws -> Data {
        for grf in grfs {
            if grf.entry(at: path) != nil {
                return try grf.contentsOfEntry(at: path)
            }
        }
        throw GameResourceError.resourceNotFound
    }
}
