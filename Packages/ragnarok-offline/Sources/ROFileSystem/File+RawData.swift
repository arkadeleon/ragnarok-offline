//
//  File+RawData.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/11.
//

import Foundation
import ROFileFormats

extension File {
    public var rawDataRepresentable: Bool {
        guard let type else {
            return false
        }

        switch type {
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            return true
        default:
            return false
        }
    }

    public var rawData: Data? {
        guard rawDataRepresentable else {
            return nil
        }

        guard let type, let data = contents() else {
            return nil
        }

        let value: Encodable? = switch type {
        case .act: try? ACT(data: data)
        case .gat: try? GAT(data: data)
        case .gnd: try? GND(data: data)
        case .rsm: try? RSM(data: data)
        case .rsw: try? RSW(data: data)
        case .spr: try? SPR(data: data)
        case .str: try? STR(data: data)
        default: nil
        }

        guard let value else {
            return nil
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        let rawData = try? encoder.encode(value)
        return rawData
    }
}