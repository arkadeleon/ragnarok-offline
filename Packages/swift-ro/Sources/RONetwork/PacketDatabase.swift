//
//  PacketDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

let packetDatabase = PacketDatabase()

final class PacketDatabase: Sendable {
    struct Entry {
        var packetType: Int16
        var packetLength: Int16
        var functionName: String?
        var offsets: [Int] = []
    }

    let entriesByPacketType: [Int16 : Entry]

    init() {
        var entriesByPacketType: [Int16 : Entry] = [:]

        let add_packet: (Int16, Int, String?, [Int]) -> Void = { packetType, packetLength, functionName, offsets in
            if let functionName {
                if let key = entriesByPacketType.first(where: { $0.value.functionName == functionName })?.key {
                    entriesByPacketType.removeValue(forKey: key)
                }
            }

            let entry = Entry(packetType: packetType, packetLength: Int16(packetLength), functionName: functionName, offsets: offsets)
            entriesByPacketType[packetType] = entry
        }

        add_packets(add_packet)

        /// PACKET_ZC_REPUTE_INFO
        add_packet(0x0b8d, -1, nil, [])

        /// See `clif_navigateTo`
        add_packet(0x08e2, 27, nil, [])

        /// PACKET_ZC_CLOSE_DIALOG
        add_packet(0x00b6, 6, nil, [])

        self.entriesByPacketType = entriesByPacketType
    }

    func entry(forFunctionName functionName: String) -> Entry? {
        entriesByPacketType.first(where: { $0.value.functionName == functionName })?.value
    }
}
