//
//  PacketDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

let packetDatabase = PacketDatabase()

class PacketDatabase {
    struct Entry: Comparable {
        var packetType: Int16
        var packetLength: Int16
        var functionName: String?
        var offsets: [Int] = []

        static func < (lhs: Entry, rhs: Entry) -> Bool {
            lhs.packetType < rhs.packetType
        }
    }

    var entriesByPacketType: [Int16 : Entry] = [:]

    init() {
        add_from_clif_packetdb()
        add_from_clif_shuffle()

        /// PACKET_ZC_REPUTE_INFO
        add(0x0b8d, -1)

        /// See `clif_navigateTo`
        add(0x08e2, 27)

        /// PACKET_ZC_CLOSE_DIALOG
        add(0x00b6, 6)
    }

    func add(_ packetType: Int16, _ packetLength: Int16) {
        let entry = Entry(packetType: packetType, packetLength: packetLength)
        entriesByPacketType[packetType] = entry
    }

    func add(_ packetType: Int16, _ packetLength: Int16, _ functionName: String?, _ offsets: [Int]) {
        if let functionName {
            if let key = entriesByPacketType.first(where: { $0.value.functionName == functionName })?.key {
                entriesByPacketType.removeValue(forKey: key)
            }
        }

        let entry = Entry(packetType: packetType, packetLength: packetLength, functionName: functionName, offsets: offsets)
        entriesByPacketType[packetType] = entry
    }

    func entry(forFunctionName functionName: String) -> Entry? {
        entriesByPacketType.first(where: { $0.value.functionName == functionName })?.value
    }
}
