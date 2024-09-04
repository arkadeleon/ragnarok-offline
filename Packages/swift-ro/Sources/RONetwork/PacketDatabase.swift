//
//  PacketDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

import ROGenerated

let packetDatabase = PacketDatabase()

class PacketDatabase {
    struct Entry {
        var packetType: Int16
        var packetLength: Int16
        var functionName: String?
        var offsets: [Int] = []
    }

    let entriesByPacketType: [Int16 : Entry]

    init() {
        var entriesByPacketType: [Int16 : Entry] = [:]

        let packet: (Int16, Int16) -> Void = { packetType, packetLength in
            let entry = Entry(packetType: packetType, packetLength: packetLength)
            entriesByPacketType[packetType] = entry
        }

        let parseable_packet: (Int16, Int16, String?, [Int]) -> Void = { packetType, packetLength, functionName, offsets in
            if let functionName {
                if let key = entriesByPacketType.first(where: { $0.value.functionName == functionName })?.key {
                    entriesByPacketType.removeValue(forKey: key)
                }
            }

            let entry = Entry(packetType: packetType, packetLength: packetLength, functionName: functionName, offsets: offsets)
            entriesByPacketType[packetType] = entry
        }

        add_packets(packet, parseable_packet, PACKETVER: PACKET_VERSION, PACKETVER_MAIN_NUM: PACKET_VERSION_MAIN_NUMBER ?? 0, PACKETVER_RE_NUM: PACKET_VERSION_RE_NUMBER ?? 0, PACKETVER_ZERO_NUM: PACKET_VERSION_ZERO_NUMBER ?? 0)
        add_packets_shuffle(packet, parseable_packet, PACKETVER: PACKET_VERSION, PACKETVER_MAIN_NUM: PACKET_VERSION_MAIN_NUMBER ?? 0, PACKETVER_RE_NUM: PACKET_VERSION_RE_NUMBER ?? 0, PACKETVER_ZERO_NUM: PACKET_VERSION_ZERO_NUMBER ?? 0)

        /// PACKET_ZC_REPUTE_INFO
        packet(0x0b8d, -1)

        /// See `clif_navigateTo`
        packet(0x08e2, 27)

        /// PACKET_ZC_CLOSE_DIALOG
        packet(0x00b6, 6)

        self.entriesByPacketType = entriesByPacketType
    }

    func entry(forFunctionName functionName: String) -> Entry? {
        entriesByPacketType.first(where: { $0.value.functionName == functionName })?.value
    }
}
