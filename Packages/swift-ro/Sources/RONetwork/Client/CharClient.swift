//
//  CharClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/8.
//

import Combine
import Foundation

final public class CharClient: ClientBase {
    public let state: ClientState

    private var timerSubscription: AnyCancellable?

    public init(state: ClientState, charServer: CharServerInfo) {
        self.state = state

        super.init(port: charServer.port)

        registerCharServerPackets()
        registerCharPackets()

        // 0x82d
        registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.self, for: PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.packetType) { packet in
        }

        // 0x8b9
        registerPacket(PACKET_HC_SECOND_PASSWD_LOGIN.self, for: PACKET_HC_SECOND_PASSWD_LOGIN.packetType) { packet in
        }

        // 0x9a0
        registerPacket(PACKET_HC_CHARLIST_NOTIFY.self, for: PACKET_HC_CHARLIST_NOTIFY.packetType) { packet in
        }

        // 0x20d
        registerPacket(PACKET_HC_BLOCK_CHARACTER.self, for: PACKET_HC_BLOCK_CHARACTER.packetType) { packet in
        }

        // 0x81
        registerPacket(PACKET_SC_NOTIFY_BAN.self, for: PACKET_SC_NOTIFY_BAN.packetType) { [unowned self] packet in
            let event = AuthenticationEvents.Banned(errorCode: packet.errorCode)
            self.postEvent(event)
        }
    }

    private func registerCharServerPackets() {
        // 0x6b
        registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION.self, for: PACKET_HC_ACCEPT_ENTER_NEO_UNION.packetType) { [unowned self] packet in
            let event = CharServerEvents.Accepted(chars: packet.chars)
            self.postEvent(event)
        }

        // 0x6c
        registerPacket(PACKET_HC_REFUSE_ENTER.self, for: PACKET_HC_REFUSE_ENTER.packetType) { [unowned self] packet in
            let event = CharServerEvents.Refused()
            self.postEvent(event)
        }

        // 0x71, 0xac5
        registerPacket(PACKET_HC_NOTIFY_ZONESVR.self, for: PACKET_HC_NOTIFY_ZONESVR.packetType) { [unowned self] packet in
            let event = CharServerEvents.NotifyMapServer(charID: packet.charID, mapName: packet.mapName, mapServer: packet.mapServer)
            self.postEvent(event)
        }

        // 0x840
        registerPacket(PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self, for: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.packetType) { [unowned self] packet in
            let event = CharServerEvents.NotifyAccessibleMaps(accessibleMaps: packet.accessibleMaps)
            self.postEvent(event)
        }
    }

    private func registerCharPackets() {
        // 0x6d
        registerPacket(PACKET_HC_ACCEPT_MAKECHAR.self, for: PACKET_HC_ACCEPT_MAKECHAR.packetType) { [unowned self] packet in
            let event = CharEvents.MakeAccepted(char: packet.char)
            self.postEvent(event)
        }

        // 0x6e
        registerPacket(PACKET_HC_REFUSE_MAKECHAR.self, for: PACKET_HC_REFUSE_MAKECHAR.packetType) { [unowned self] packet in
            let event = CharEvents.MakeRefused()
            self.postEvent(event)
        }

        // 0x6f
        registerPacket(PACKET_HC_ACCEPT_DELETECHAR.self, for: PACKET_HC_ACCEPT_DELETECHAR.packetType) { [unowned self] packet in
            let event = CharEvents.DeleteAccepted()
            self.postEvent(event)
        }

        // 0x70
        registerPacket(PACKET_HC_REFUSE_DELETECHAR.self, for: PACKET_HC_REFUSE_DELETECHAR.packetType) { [unowned self] packet in
            let event = CharEvents.DeleteRefused(errorCode: UInt32(packet.errorCode))
            self.postEvent(event)
        }

        // 0x82a
        registerPacket(PACKET_HC_DELETE_CHAR.self, for: PACKET_HC_DELETE_CHAR.packetType) { [unowned self] packet in
            if packet.result == 1 {
                let event = CharEvents.DeleteAccepted()
                self.postEvent(event)
            } else {
                let event = CharEvents.DeleteRefused(errorCode: packet.result)
                self.postEvent(event)
            }
        }

        // 0x82c
        registerPacket(PACKET_HC_DELETE_CHAR_CANCEL.self, for: PACKET_HC_DELETE_CHAR_CANCEL.packetType) { [unowned self] packet in
            let event = CharEvents.DeleteCancelled()
            self.postEvent(event)
        }

        // 0x828
        registerPacket(PACKET_HC_DELETE_CHAR_RESERVED.self, for: PACKET_HC_DELETE_CHAR_RESERVED.packetType) { [unowned self] packet in
            let event = CharEvents.DeletionDateResponse(deletionDate: packet.deletionDate)
            self.postEvent(event)
        }
    }

    /// Enter.
    ///
    /// Send ``PACKET_CH_ENTER``
    ///
    /// Receive Account ID
    ///
    /// Receive ``PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER`` +
    ///         ``PACKET_HC_ACCEPT_ENTER_NEO_UNION`` +
    ///         ``PACKET_HC_CHARLIST_NOTIFY`` +
    ///         ``PACKET_HC_BLOCK_CHARACTER`` +
    ///         ``PACKET_HC_SECOND_PASSWD_LOGIN`` or
    ///         ``PACKET_HC_REFUSE_ENTER``
    public func enter() {
        var packet = PACKET_CH_ENTER()
        packet.accountID = state.accountID
        packet.loginID1 = state.loginID1
        packet.loginID2 = state.loginID2
        packet.clientType = state.langType
        packet.sex = state.sex

        sendPacket(packet)

        receiveData { data in
            self.state.accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })

            self.receivePacket()
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_PING`` every 12 seconds.
    public func keepAlive() {
        let accountID = state.accountID

        timerSubscription = Timer.publish(every: 12, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CZ_PING()
                packet.accountID = accountID

                self?.sendPacket(packet)
            }
    }

    /// Make char.
    ///
    /// Send ``PACKET_CH_MAKE_CHAR``
    ///
    /// Receive ``PACKET_HC_ACCEPT_MAKECHAR`` or
    ///         ``PACKET_HC_REFUSE_MAKECHAR``
    public func makeChar(char: CharInfo) {
        var packet = PACKET_CH_MAKE_CHAR()
        packet.name = char.name
        packet.str = char.str
        packet.agi = char.agi
        packet.vit = char.vit
        packet.int = char.int
        packet.dex = char.dex
        packet.luk = char.luk
        packet.slot = char.slot
        packet.hairColor = char.hairColor
        packet.hairStyle = char.hair
        packet.job = char.job
        packet.sex = char.sex

        sendPacket(packet)
    }

    /// Delete char.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR``
    ///
    /// if ``PACKET_VERSION`` > 20100803
    ///
    /// Receive ``PACKET_HC_ACCEPT_DELETECHAR`` or
    ///         ``PACKET_HC_REFUSE_DELETECHAR``
    ///
    /// else
    ///
    /// Receive ``PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER`` +
    ///         ``PACKET_HC_ACCEPT_ENTER_NEO_UNION`` +
    ///         ``PACKET_HC_CHARLIST_NOTIFY`` +
    ///         ``PACKET_HC_BLOCK_CHARACTER`` +
    ///         ``PACKET_HC_DELETE_CHAR``
    public func deleteChar(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR()
        packet.charID = charID

        sendPacket(packet)
    }

    /// Request deletion date.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_RESERVED``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_RESERVED``
    public func requestDeletionDate(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_RESERVED()
        packet.charID = charID

        sendPacket(packet)
    }

    /// Cancel delete.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_CANCEL``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_CANCEL``
    public func cancelDelete(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_CANCEL()
        packet.charID = charID

        sendPacket(packet)
    }

    /// Select char.
    ///
    /// Send ``PACKET_CH_SELECT_CHAR``
    ///
    /// Receive (
    ///     ``PACKET_VERSION`` >= 20100714 ? ``PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME`` : ``PACKET_SC_NOTIFY_BAN``
    /// ) when map server is not available.
    ///
    /// Receive ``PACKET_HC_REFUSE_ENTER`` when refused.
    ///
    /// Receive ``PACKET_HC_NOTIFY_ZONESVR`` when accepted.
    public func selectChar(slot: UInt8) {
        var packet = PACKET_CH_SELECT_CHAR()
        packet.slot = slot

        sendPacket(packet)
    }
}
