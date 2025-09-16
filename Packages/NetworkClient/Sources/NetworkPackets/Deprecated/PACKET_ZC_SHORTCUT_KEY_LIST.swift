//
//  PACKET_ZC_SHORTCUT_KEY_LIST.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/29.
//

import BinaryIO

/// See `clif_hotkeys_send`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_SHORTCUT_KEY_LIST: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION_MAIN_NUMBER >= 20190522 || PACKET_VERSION_RE_NUMBER >= 20190508 || PACKET_VERSION_ZERO_NUMBER >= 20190605 {
            0xb20
        } else if PACKET_VERSION_MAIN_NUMBER >= 20141022 || PACKET_VERSION_RE_NUMBER >= 20141015 || PACKET_VERSION_ZERO_NUMBER != nil {
            0xa00
        } else if PACKET_VERSION_MAIN_NUMBER >= 20090617 || PACKET_VERSION_RE_NUMBER >= 20090617 || PACKET_VERSION_SAK_NUMBER >= 20090617 {
            0x7d9
        } else if PACKET_VERSION_MAIN_NUMBER >= 20090603 || PACKET_VERSION_RE_NUMBER >= 20090603 || PACKET_VERSION_SAK_NUMBER >= 20090603 {
            0x7d9
        } else if PACKET_VERSION_MAIN_NUMBER >= 20070711 || PACKET_VERSION_RE_NUMBER >= 20080827 || PACKET_VERSION_AD_NUMBER >= 20070711 || PACKET_VERSION_SAK_NUMBER >= 20070628 {
            0x2b9
        } else {
            0x0
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION_MAIN_NUMBER >= 20190522 || PACKET_VERSION_RE_NUMBER >= 20190508 || PACKET_VERSION_ZERO_NUMBER >= 20190605 {
            2 + 1 + 2 + _HotkeyInfo.decodedLength * 38
        } else if PACKET_VERSION_MAIN_NUMBER >= 20141022 || PACKET_VERSION_RE_NUMBER >= 20141015 || PACKET_VERSION_ZERO_NUMBER != nil {
            2 + 1 + _HotkeyInfo.decodedLength * 38
        } else if PACKET_VERSION_MAIN_NUMBER >= 20090617 || PACKET_VERSION_RE_NUMBER >= 20090617 || PACKET_VERSION_SAK_NUMBER >= 20090617 {
            2 + _HotkeyInfo.decodedLength * 38
        } else if PACKET_VERSION_MAIN_NUMBER >= 20090603 || PACKET_VERSION_RE_NUMBER >= 20090603 || PACKET_VERSION_SAK_NUMBER >= 20090603 {
            2 + _HotkeyInfo.decodedLength * 36
        } else if PACKET_VERSION_MAIN_NUMBER >= 20070711 || PACKET_VERSION_RE_NUMBER >= 20080827 || PACKET_VERSION_AD_NUMBER >= 20070711 || PACKET_VERSION_SAK_NUMBER >= 20070628 {
            2 + _HotkeyInfo.decodedLength * 27
        } else {
            0
        }
    }

    public var rotate: Int8
    public var tab: Int16
    public var hotkeys: [_HotkeyInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        if PACKET_VERSION_MAIN_NUMBER >= 20190522 || PACKET_VERSION_RE_NUMBER >= 20190508 || PACKET_VERSION_ZERO_NUMBER >= 20190605 {
            rotate = try decoder.decode(Int8.self)
            tab = try decoder.decode(Int16.self)
            hotkeys = []
            for _ in 0..<38 {
                let hotkey = try _HotkeyInfo(from: decoder)
                hotkeys.append(hotkey)
            }
        } else if PACKET_VERSION_MAIN_NUMBER >= 20141022 || PACKET_VERSION_RE_NUMBER >= 20141015 || PACKET_VERSION_ZERO_NUMBER != nil {
            rotate = try decoder.decode(Int8.self)
            tab = 0
            hotkeys = []
            for _ in 0..<38 {
                let hotkey = try _HotkeyInfo(from: decoder)
                hotkeys.append(hotkey)
            }
        } else if PACKET_VERSION_MAIN_NUMBER >= 20090617 || PACKET_VERSION_RE_NUMBER >= 20090617 || PACKET_VERSION_SAK_NUMBER >= 20090617 {
            rotate = 0
            tab = 0
            hotkeys = []
            for _ in 0..<38 {
                let hotkey = try _HotkeyInfo(from: decoder)
                hotkeys.append(hotkey)
            }
        } else if PACKET_VERSION_MAIN_NUMBER >= 20090603 || PACKET_VERSION_RE_NUMBER >= 20090603 || PACKET_VERSION_SAK_NUMBER >= 20090603 {
            rotate = 0
            tab = 0
            hotkeys = []
            for _ in 0..<36 {
                let hotkey = try _HotkeyInfo(from: decoder)
                hotkeys.append(hotkey)
            }
        } else if PACKET_VERSION_MAIN_NUMBER >= 20070711 || PACKET_VERSION_RE_NUMBER >= 20080827 || PACKET_VERSION_AD_NUMBER >= 20070711 || PACKET_VERSION_SAK_NUMBER >= 20070628 {
            rotate = 0
            tab = 0
            hotkeys = []
            for _ in 0..<27 {
                let hotkey = try _HotkeyInfo(from: decoder)
                hotkeys.append(hotkey)
            }
        } else {
            rotate = 0
            tab = 0
            hotkeys = []
        }
    }
}
