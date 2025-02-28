//
//  ObservableFile+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/15.
//

import Foundation
import ROFileFormats

extension File {
    var jsonRepresentable: Bool {
        switch type {
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            true
        default:
            false
        }
    }

    var json: String? {
        guard jsonRepresentable else {
            return nil
        }

        guard let data = contents() else {
            return nil
        }

        let json: String? = switch type {
        case .act: try? ACT(data: data).json
        case .gat: try? GAT(data: data).json
        case .gnd: try? GND(data: data).json
        case .rsm: try? RSM(data: data).json
        case .rsw: try? RSW(data: data).json
        case .spr: try? SPR(data: data).json
        case .str: try? STR(data: data).json
        default: nil
        }

        return json
    }
}
