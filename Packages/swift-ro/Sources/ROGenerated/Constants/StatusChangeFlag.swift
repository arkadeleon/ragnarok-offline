//
//  StatusChangeFlag.swift
//  RagnarokOffline
//
//  Generated by ROCodeGenerator.
//

/// Converted from `e_status_change_flag` in `map/status.hpp`.
public enum StatusChangeFlag: Int, CaseIterable, Sendable {
    case none = 0
    case bleffect = 1
    case displaypc = 2
    case noclearbuff = 3
    case noremoveondead = 4
    case nodispell = 5
    case noclearance = 6
    case nobanishingbuster = 7
    case nosave = 8
    case nosaveinfinite = 9
    case removeondamaged = 10
    case removeonrefresh = 11
    case removeonluxanima = 12
    case stopattacking = 13
    case stopcasting = 14
    case stopwalking = 15
    case bossresist = 16
    case mvpresist = 17
    case setstand = 18
    case failedmado = 19
    case debuff = 20
    case removeonchangemap = 21
    case removeonmapwarp = 22
    case removechemicalprotect = 23
    case overlapignorelevel = 24
    case sendoption = 25
    case ontouch = 26
    case unitmove = 27
    case nonplayer = 28
    case sendlook = 29
    case displaynpc = 30
    case requireweapon = 31
    case requireshield = 32
    case moblosetarget = 33
    case removeelementaloption = 34
    case supernoviceangel = 35
    case taekwonangel = 36
    case madocancel = 37
    case madoendcancel = 38
    case restartonmapwarp = 39
    case spreadeffect = 40
    case sendval1 = 41
    case sendval2 = 42
    case sendval3 = 43
    case noforcedend = 44
    case nowarning = 45
    case removeonunequip = 46
    case removeonunequipweapon = 47
    case removeonunequiparmor = 48
    case removeonhermode = 49
    case requirenoweapon = 50
    case removefromhomonwarp = 51
    case removefromhomonmapwarp = 52
}

extension StatusChangeFlag: CodingKey {
    public var stringValue: String {
        switch self {
        case .none: "NONE"
        case .bleffect: "BLEFFECT"
        case .displaypc: "DISPLAYPC"
        case .noclearbuff: "NOCLEARBUFF"
        case .noremoveondead: "NOREMOVEONDEAD"
        case .nodispell: "NODISPELL"
        case .noclearance: "NOCLEARANCE"
        case .nobanishingbuster: "NOBANISHINGBUSTER"
        case .nosave: "NOSAVE"
        case .nosaveinfinite: "NOSAVEINFINITE"
        case .removeondamaged: "REMOVEONDAMAGED"
        case .removeonrefresh: "REMOVEONREFRESH"
        case .removeonluxanima: "REMOVEONLUXANIMA"
        case .stopattacking: "STOPATTACKING"
        case .stopcasting: "STOPCASTING"
        case .stopwalking: "STOPWALKING"
        case .bossresist: "BOSSRESIST"
        case .mvpresist: "MVPRESIST"
        case .setstand: "SETSTAND"
        case .failedmado: "FAILEDMADO"
        case .debuff: "DEBUFF"
        case .removeonchangemap: "REMOVEONCHANGEMAP"
        case .removeonmapwarp: "REMOVEONMAPWARP"
        case .removechemicalprotect: "REMOVECHEMICALPROTECT"
        case .overlapignorelevel: "OVERLAPIGNORELEVEL"
        case .sendoption: "SENDOPTION"
        case .ontouch: "ONTOUCH"
        case .unitmove: "UNITMOVE"
        case .nonplayer: "NONPLAYER"
        case .sendlook: "SENDLOOK"
        case .displaynpc: "DISPLAYNPC"
        case .requireweapon: "REQUIREWEAPON"
        case .requireshield: "REQUIRESHIELD"
        case .moblosetarget: "MOBLOSETARGET"
        case .removeelementaloption: "REMOVEELEMENTALOPTION"
        case .supernoviceangel: "SUPERNOVICEANGEL"
        case .taekwonangel: "TAEKWONANGEL"
        case .madocancel: "MADOCANCEL"
        case .madoendcancel: "MADOENDCANCEL"
        case .restartonmapwarp: "RESTARTONMAPWARP"
        case .spreadeffect: "SPREADEFFECT"
        case .sendval1: "SENDVAL1"
        case .sendval2: "SENDVAL2"
        case .sendval3: "SENDVAL3"
        case .noforcedend: "NOFORCEDEND"
        case .nowarning: "NOWARNING"
        case .removeonunequip: "REMOVEONUNEQUIP"
        case .removeonunequipweapon: "REMOVEONUNEQUIPWEAPON"
        case .removeonunequiparmor: "REMOVEONUNEQUIPARMOR"
        case .removeonhermode: "REMOVEONHERMODE"
        case .requirenoweapon: "REQUIRENOWEAPON"
        case .removefromhomonwarp: "REMOVEFROMHOMONWARP"
        case .removefromhomonmapwarp: "REMOVEFROMHOMONMAPWARP"
        }
    }

    public init?(stringValue: String) {
        switch stringValue.uppercased() {
        case "NONE": self = .none
        case "BLEFFECT": self = .bleffect
        case "DISPLAYPC": self = .displaypc
        case "NOCLEARBUFF": self = .noclearbuff
        case "NOREMOVEONDEAD": self = .noremoveondead
        case "NODISPELL": self = .nodispell
        case "NOCLEARANCE": self = .noclearance
        case "NOBANISHINGBUSTER": self = .nobanishingbuster
        case "NOSAVE": self = .nosave
        case "NOSAVEINFINITE": self = .nosaveinfinite
        case "REMOVEONDAMAGED": self = .removeondamaged
        case "REMOVEONREFRESH": self = .removeonrefresh
        case "REMOVEONLUXANIMA": self = .removeonluxanima
        case "STOPATTACKING": self = .stopattacking
        case "STOPCASTING": self = .stopcasting
        case "STOPWALKING": self = .stopwalking
        case "BOSSRESIST": self = .bossresist
        case "MVPRESIST": self = .mvpresist
        case "SETSTAND": self = .setstand
        case "FAILEDMADO": self = .failedmado
        case "DEBUFF": self = .debuff
        case "REMOVEONCHANGEMAP": self = .removeonchangemap
        case "REMOVEONMAPWARP": self = .removeonmapwarp
        case "REMOVECHEMICALPROTECT": self = .removechemicalprotect
        case "OVERLAPIGNORELEVEL": self = .overlapignorelevel
        case "SENDOPTION": self = .sendoption
        case "ONTOUCH": self = .ontouch
        case "UNITMOVE": self = .unitmove
        case "NONPLAYER": self = .nonplayer
        case "SENDLOOK": self = .sendlook
        case "DISPLAYNPC": self = .displaynpc
        case "REQUIREWEAPON": self = .requireweapon
        case "REQUIRESHIELD": self = .requireshield
        case "MOBLOSETARGET": self = .moblosetarget
        case "REMOVEELEMENTALOPTION": self = .removeelementaloption
        case "SUPERNOVICEANGEL": self = .supernoviceangel
        case "TAEKWONANGEL": self = .taekwonangel
        case "MADOCANCEL": self = .madocancel
        case "MADOENDCANCEL": self = .madoendcancel
        case "RESTARTONMAPWARP": self = .restartonmapwarp
        case "SPREADEFFECT": self = .spreadeffect
        case "SENDVAL1": self = .sendval1
        case "SENDVAL2": self = .sendval2
        case "SENDVAL3": self = .sendval3
        case "NOFORCEDEND": self = .noforcedend
        case "NOWARNING": self = .nowarning
        case "REMOVEONUNEQUIP": self = .removeonunequip
        case "REMOVEONUNEQUIPWEAPON": self = .removeonunequipweapon
        case "REMOVEONUNEQUIPARMOR": self = .removeonunequiparmor
        case "REMOVEONHERMODE": self = .removeonhermode
        case "REQUIRENOWEAPON": self = .requirenoweapon
        case "REMOVEFROMHOMONWARP": self = .removefromhomonwarp
        case "REMOVEFROMHOMONMAPWARP": self = .removefromhomonmapwarp
        default: return nil
        }
    }

    public var intValue: Int? {
        rawValue
    }

    public init?(intValue: Int) {
        self.init(rawValue: intValue)
    }
}

extension StatusChangeFlag: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }
}

extension StatusChangeFlag: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let value = Self.init(stringValue: stringValue) {
            self = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not initialize \(Self.self) from invalid string value \(stringValue)")
        }
    }
}
