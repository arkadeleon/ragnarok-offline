//
//  File+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/11.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

extension File {
    var jsonRepresentable: Bool {
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

    var jsonRepresentation: String? {
        guard jsonRepresentable else {
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

        guard let jsonData = try? encoder.encode(value) else {
            return nil
        }

        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    }
}
