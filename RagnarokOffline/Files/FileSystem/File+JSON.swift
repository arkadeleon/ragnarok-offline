//
//  File+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/15.
//

import Foundation
import RagnarokFileFormats

extension File {
    var jsonRepresentable: Bool {
        switch utType {
        case .act, .gat, .gnd, .imf, .rsm, .rsw, .spr, .str:
            true
        default:
            false
        }
    }

    func json() async throws -> Data {
        guard jsonRepresentable else {
            throw FileError.jsonConversionFailed
        }

        let data = try await contents()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )

        switch utType {
        case .act:
            let act = try ACT(data: data)
            let json = try encoder.encode(act)
            return json
        case .gat:
            let gat = try GAT(data: data)
            let json = try encoder.encode(gat)
            return json
        case .gnd:
            let gnd = try GND(data: data)
            let json = try encoder.encode(gnd)
            return json
        case .imf:
            let imf = try IMF(data: data)
            let json = try encoder.encode(imf)
            return json
        case .rsm:
            let rsm = try RSM(data: data)
            let json = try encoder.encode(rsm)
            return json
        case .rsw:
            let rsw = try RSW(data: data)
            let json = try encoder.encode(rsw)
            return json
        case .spr:
            let spr = try SPR(data: data)
            let json = try encoder.encode(spr)
            return json
        case .str:
            let str = try STR(data: data)
            let json = try encoder.encode(str)
            return json
        default:
            throw FileError.jsonConversionFailed
        }
    }
}
