//
//  File+Info.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/11.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

extension File {
    var hasInfo: Bool {
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

    var info: Encodable? {
        guard let type else {
            return nil
        }

        switch type {
        case .act:
            guard let data = contents() else {
                return nil
            }
            let act = try? ACT(data: data)
            return act
        case .gat:
            guard let data = contents() else {
                return nil
            }
            let gat = try? GAT(data: data)
            return gat
        case .gnd:
            guard let data = contents() else {
                return nil
            }
            let gnd = try? GND(data: data)
            return gnd
        case .rsm:
            guard let data = contents() else {
                return nil
            }
            let rsm = try? RSM(data: data)
            return rsm
        case .rsw:
            guard let data = contents() else {
                return nil
            }
            let rsw = try? RSW(data: data)
            return rsw
        case .spr:
            guard let data = contents() else {
                return nil
            }
            let spr = try? SPR(data: data)
            return spr
        case .str:
            guard let data = contents() else {
                return nil
            }
            let str = try? STR(data: data)
            return str
        default:
            return nil
        }
    }
}
