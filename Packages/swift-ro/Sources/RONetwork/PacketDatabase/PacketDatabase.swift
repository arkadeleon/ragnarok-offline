//
//  PacketDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/21.
//

let packetDatabase = PacketDatabase()

class PacketDatabase {
    struct Entry {
        var packetLength: Int16
        var functionName: String?
        var offsets: [Int] = []
    }

    var entries: [UInt16 : Entry] = [:]

    init() {
        add_from_clif_packetdb()
        add_from_clif_shuffle()
    }

    func add(_ packetType: UInt16, _ packetLength: Int16) {
        let entry = Entry(packetLength: packetLength)
        entries[packetType] = entry
    }

    func add(_ packetType: UInt16, _ packetLength: Int16, _ functionName: String?, _ offsets: [Int]) {
        let entry = Entry(packetLength: packetLength, functionName: functionName, offsets: offsets)
        entries[packetType] = entry
    }
}
