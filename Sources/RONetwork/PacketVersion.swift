//
//  PacketVersion.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

import rAthenaCommon

/// See ``PACKETVER``
public let PACKET_VERSION = RA_PACKETVER

/// See ``PACKETVER_RE``
public let PACKET_VERSION_RE = (PACKET_VERSION > 20151104 && PACKET_VERSION < 20180704) || (PACKET_VERSION >= 20200902 && PACKET_VERSION <= 20211118)

/// See ``PACKETVER_MAIN_NUM``
public let PACKET_VERSION_MAIN_NUMBER = !PACKET_VERSION_RE ? PACKET_VERSION : nil

/// See ``PACKETVER_RE_NUM``
public let PACKET_VERSION_RE_NUMBER = PACKET_VERSION_RE ? PACKET_VERSION : nil

public struct PacketVersion {

    /// See ``PACKETVER``
    public let number: Int

    /// See ``PACKETVER_RE``
    public var supportsRE: Bool {
        if (number > 20151104 && number < 20180704) ||
            (number >= 20200902 && number <= 20211118) {
            true
        } else {
            false
        }
    }

    /// See ``PACKETVER_MAIN_NUM``
    public var mainNumber: Int? {
        !supportsRE ? number : nil
    }

    /// See ``PACKETVER_RE_NUM``
    public var reNumber: Int? {
        supportsRE ? number : nil
    }

    /// See ``PACKET_OBFUSCATION``
    public var supportsObfuscation: Bool {
        number >= 20110817
    }

    /// See ``OFFICIAL_GUILD_STORAGE``
    public var supportsOfficialGuildStorage: Bool {
        number >= 20131223
    }

    /// See ``PACKETVER_SUPPORTS_PINCODE``
    public var supportsPincode: Bool {
        number >= 20110309
    }

    /// See ``PACKETVER_CHAR_DELETEDATE``
    public var supportsCharDeleteRemainingTime: Bool {
        (number > 20130000 && number <= 20141022) || number >= 20150513
    }

    /// See ``PACKETVER_SUPPORTS_SALES``
    public var supportsSales: Bool {
        number >= 20131223
    }

    /// See ``WEB_SERVER_ENABLE``
    public var supportsWebServer: Bool {
        number > 20200300
    }

    public init(number: Int) {
        self.number = number
    }
}

//func < (lhs: Int?, rhs: Int) -> Bool {
//    if let lhs {
//        lhs < rhs
//    } else {
//        false
//    }
//}

//func <= (lhs: Int?, rhs: Int) -> Bool {
//    if let lhs {
//        lhs <= rhs
//    } else {
//        false
//    }
//}

func >= (lhs: Int?, rhs: Int) -> Bool {
    if let lhs {
        lhs >= rhs
    } else {
        false
    }
}

func > (lhs: Int?, rhs: Int) -> Bool {
    if let lhs {
        lhs > rhs
    } else {
        false
    }
}
