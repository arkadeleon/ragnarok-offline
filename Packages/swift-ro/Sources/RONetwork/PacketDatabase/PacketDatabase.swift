//
//  PacketDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

let packetDatabase = PacketDatabase()

class PacketDatabase {
    struct Entry: Comparable {
        var packetType: UInt16
        var packetLength: Int16
        var functionName: String?
        var offsets: [Int] = []

        static func < (lhs: Entry, rhs: Entry) -> Bool {
            lhs.packetType < rhs.packetType
        }
    }

    var entriesByPacketType: [UInt16 : Entry] = [:]

    init() {
        add_from_clif_packetdb()
        add_from_clif_shuffle()
    }

    func add(_ packetType: UInt16, _ packetLength: Int16) {
        let entry = Entry(packetType: packetType, packetLength: packetLength)
        entriesByPacketType[packetType] = entry
    }

    func add(_ packetType: UInt16, _ packetLength: Int16, _ functionName: String?, _ offsets: [Int]) {
        let entry = Entry(packetType: packetType, packetLength: packetLength, functionName: functionName, offsets: offsets)
        entriesByPacketType[packetType] = entry
    }

    func entries(forFunctionName functionName: String) -> [Entry] {
        entriesByPacketType.filter({ $0.value.functionName == functionName }).values.sorted()
    }
}
