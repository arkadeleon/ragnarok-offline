//
//  CharServerEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROPackets

public enum CharServerEvents {
    public struct Accepted: Event {
        public let chars: [CharInfo]

        init(packet: PACKET_HC_ACCEPT_ENTER_NEO_UNION) {
            self.chars = packet.chars
        }
    }

    public struct Refused: Event {
    }

    public struct NotifyMapServer: Event {
        public let charID: UInt32
        public let mapName: String
        public let mapServer: MapServerInfo

        init(packet: PACKET_HC_NOTIFY_ZONESVR) {
            self.charID = packet.charID
            self.mapName = packet.mapName
            self.mapServer = packet.mapServer
        }
    }

    public struct NotifyAccessibleMaps: Event {
        public let accessibleMaps: [PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME_sub]

        init(packet: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME) {
            self.accessibleMaps = packet.maps
        }
    }
}
