//
//  CharClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/8.
//

import Foundation

final public class CharClient {
    public let state: ClientState

    public var onAcceptEnterHeader: (() -> Void)?
    public var onAcceptEnter: ((_ chars: [CharInfo]) -> Void)?
    public var onRefuseEnter: (() -> Void)?
    public var onAcceptMakeChar: (() -> Void)?
    public var onRefuseMakeChar: (() -> Void)?
    public var onNotifyZoneServer: ((_ mapName: String, _ mapServer: MapServerInfo) -> Void)?
    public var onError: ((_ error: any Error) -> Void)?

    private let connection: ClientConnection

    private var keepAliveTimer: Timer?

    public init(state: ClientState, charServer: CharServerInfo) {
        self.state = state

        connection = ClientConnection(port: charServer.port)

        connection.errorHandler = { [weak self] error in
            self?.onError?(error)
        }

        // 0x6b
        connection.registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION.self) { [weak self] packet in
            self?.onAcceptEnter?(packet.chars)
        }

        // 0x6c
        connection.registerPacket(PACKET_HC_REFUSE_ENTER.self) { [weak self] packet in
            self?.onRefuseEnter?()
        }

        // 0x6d
        connection.registerPacket(PACKET_HC_ACCEPT_MAKECHAR.self) { [weak self] packet in
            self?.onAcceptMakeChar?()
        }

        // 0x6e
        connection.registerPacket(PACKET_HC_REFUSE_MAKECHAR.self) { [weak self] packet in
            self?.onRefuseMakeChar?()
        }

        // 0x6f
        connection.registerPacket(PACKET_HC_ACCEPT_DELETECHAR.self) { [weak self] packet in
        }

        // 0x70
        connection.registerPacket(PACKET_HC_REFUSE_DELETECHAR.self) { [weak self] packet in
        }

        // 0x71, 0xac5
        connection.registerPacket(PACKET_HC_NOTIFY_ZONESVR.self) { [weak self] packet in
            self?.state.charID = packet.charID
            self?.onNotifyZoneServer?(packet.mapName, packet.mapServer)
        }

        // 0x20d
        connection.registerPacket(PACKET_HC_BLOCK_CHARACTER.self) { [weak self] packet in
        }

        // 0x828
        connection.registerPacket(PACKET_HC_DELETE_CHAR_RESERVED.self) { [weak self] packet in
        }

        // 0x82a
        connection.registerPacket(PACKET_HC_DELETE_CHAR.self) { [weak self] packet in
        }

        // 0x82c
        connection.registerPacket(PACKET_HC_DELETE_CHAR_CANCEL.self) { [weak self] packet in
        }

        // 0x82d
        connection.registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.self) { [weak self] packet in
            self?.onAcceptEnterHeader?()
        }

        // 0x840
        connection.registerPacket(PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self) { [weak self] packet in
        }

        // 0x8b9
        connection.registerPacket(PACKET_HC_SECOND_PASSWD_LOGIN.self) { [weak self] packet in
        }

        // 0x9a0
        connection.registerPacket(PACKET_HC_CHARLIST_NOTIFY.self) { [weak self] packet in
        }
    }

    public func connect() {
        connection.start()
    }

    public func disconnect() {
        connection.cancel()
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

        connection.sendPacket(packet)

        connection.receiveData { data in
            self.state.accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })

            self.connection.receivePacket()
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_PING`` every 12 seconds.
    public func keepAlive() {
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            var packet = PACKET_CZ_PING()
            packet.accountID = self.state.accountID

            self.connection.sendPacket(packet)
        }
        keepAliveTimer?.fire()
    }

    /// Make char.
    ///
    /// Send ``PACKET_CH_MAKE_CHAR``
    ///
    /// Receive ``PACKET_HC_ACCEPT_MAKECHAR`` or
    ///         ``PACKET_HC_REFUSE_MAKECHAR``
    public func makeChar(name: String, str: UInt8, agi: UInt8, vit: UInt8, int: UInt8, dex: UInt8, luk: UInt8) {
        var packet = PACKET_CH_MAKE_CHAR()
        packet.name = name
        packet.str = str
        packet.agi = agi
        packet.vit = vit
        packet.int = int
        packet.dex = dex
        packet.luk = luk

        connection.sendPacket(packet)
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

        connection.sendPacket(packet)
    }

    /// Request deletion date.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_RESERVED``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_RESERVED``
    public func requestDeletionDate(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_RESERVED()
        packet.charID = charID

        connection.sendPacket(packet)
    }

    /// Cancel delete.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_CANCEL``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_CANCEL``
    public func cancelDelete(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_CANCEL()
        packet.charID = charID

        connection.sendPacket(packet)
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

        connection.sendPacket(packet)
    }
}
