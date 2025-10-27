//
//  PacketVersion.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

/// See ``PACKETVER``
public let PACKET_VERSION = 20211103

/// See ``PACKETVER_RE``
public let PACKET_VERSION_RE = (PACKET_VERSION > 20151104 && PACKET_VERSION < 20180704) || (PACKET_VERSION >= 20200902 && PACKET_VERSION <= 20211118)

/// See ``PACKETVER_MAIN_NUM``
public let PACKET_VERSION_MAIN_NUMBER = !PACKET_VERSION_RE ? PACKET_VERSION : nil

/// See ``PACKETVER_RE_NUM``
public let PACKET_VERSION_RE_NUMBER = PACKET_VERSION_RE ? PACKET_VERSION : nil

/// See?
public let PACKET_VERSION_ZERO_NUMBER: Int? = nil
public let PACKET_VERSION_SAK_NUMBER: Int? = nil
public let PACKET_VERSION_AD_NUMBER: Int? = nil

/// See ``PACKET_OBFUSCATION``
public let PACKET_VERSION_OBFUSCATION = PACKET_VERSION >= 20110817

/// See ``OFFICIAL_GUILD_STORAGE``
public let PACKET_VERSION_OFFICIAL_GUILD_STORAGE = PACKET_VERSION >= 20131223

/// See ``PACKETVER_SUPPORTS_PINCODE``
public let PACKET_VERSION_SUPPORTS_PINCODE = PACKET_VERSION >= 20110309

/// See ``PACKETVER_CHAR_DELETEDATE``
public let PACKET_VERSION_CHAR_DELETEDATE = (PACKET_VERSION > 20130000 && PACKET_VERSION <= 20141022) || PACKET_VERSION >= 20150513

/// See ``PACKETVER_SUPPORTS_SALES``
public let PACKET_VERSION_SUPPORTS_SALES = PACKET_VERSION >= 20131223

/// See ``WEB_SERVER_ENABLE``
public let PACKET_VERSION_SERVER_ENABLE = PACKET_VERSION > 20200300

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
