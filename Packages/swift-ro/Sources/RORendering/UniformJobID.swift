//
//  UniformJobID.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/12.
//

public struct UniformJobID: RawRepresentable, ExpressibleByIntegerLiteral, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

extension UniformJobID {
    var isPlayer: Bool {
        switch rawValue {
        case 0..<45: true
        case 4001...4316: true
        default: false
        }
    }

    var isBabyPlayer: Bool {
        switch rawValue {
        case 4023...4045: true
        case 4096...4112: true
        case 4158...4182: true
        case 4205...4210: true
        case 4220...4238: true
        case 4191, 4193, 4195, 4196, 4241, 4242, 4244, 4247, 4248: true
        default: false
        }
    }

    var isMadogear: Bool {
        switch rawValue {
        case 4086, 4087, 4112, 4279: true
        default: false
        }
    }

    var isNPC: Bool {
        switch rawValue {
        case 45..<1000: true
        case 10001..<19999: true
        default: false
        }
    }

    var isMonster: Bool {
        switch rawValue {
        case 1001..<3999: true
        case 20000...: true
        default: false
        }
    }

    var isHomunculus: Bool {
        switch rawValue {
        case 6001...6052: true
        default: false
        }
    }

    var isMercenary: Bool {
        switch rawValue {
        case 6017...6046: true
        default: false
        }
    }

    var isDoram: Bool {
        switch rawValue {
        case 4217...4221: true
        case 4308, 4315: true
        default: false
        }
    }
}
