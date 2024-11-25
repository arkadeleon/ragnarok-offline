//
//  CharClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/8.
//

import Combine
import Foundation

final public class CharClient {
    public let state: ClientState

    private let connection: ClientConnection

    private let eventSubject = PassthroughSubject<any Event, Never>()
    private var subscriptions = Set<AnyCancellable>()

    public init(state: ClientState, charServer: CharServerInfo) {
        self.state = state

        connection = ClientConnection(port: charServer.port)

        connection.errorHandler = { [weak self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self?.eventSubject.send(event)
        }

        registerCharServerPackets()
        registerCharPackets()

        // 0x82d
        connection.registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.self, for: PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.packetType)

        // 0x8b9
        connection.registerPacket(PACKET_HC_SECOND_PASSWD_LOGIN.self, for: PACKET_HC_SECOND_PASSWD_LOGIN.packetType)

        // 0x9a0
        connection.registerPacket(PACKET_HC_CHARLIST_NOTIFY.self, for: PACKET_HC_CHARLIST_NOTIFY.packetType)

        // 0x20d
        connection.registerPacket(PACKET_HC_BLOCK_CHARACTER.self, for: PACKET_HC_BLOCK_CHARACTER.packetType)

        // 0x81
        connection.registerPacket(PACKET_SC_NOTIFY_BAN.self, for: PACKET_SC_NOTIFY_BAN.packetType)
            .map { packet in
                AuthenticationEvents.Banned(errorCode: packet.errorCode)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerCharServerPackets() {
        // 0x6b
        connection.registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION.self, for: PACKET_HC_ACCEPT_ENTER_NEO_UNION.packetType)
            .map { packet in
                CharServerEvents.Accepted(chars: packet.chars)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x6c
        connection.registerPacket(PACKET_HC_REFUSE_ENTER.self, for: PACKET_HC_REFUSE_ENTER.packetType)
            .map { packet in
                CharServerEvents.Refused()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x71, 0xac5
        connection.registerPacket(PACKET_HC_NOTIFY_ZONESVR.self, for: PACKET_HC_NOTIFY_ZONESVR.packetType)
            .map { packet in
                CharServerEvents.NotifyMapServer(charID: packet.charID, mapName: packet.mapName, mapServer: packet.mapServer)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x840
        connection.registerPacket(PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self, for: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.packetType)
            .map { packet in
                CharServerEvents.NotifyAccessibleMaps(accessibleMaps: packet.accessibleMaps)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerCharPackets() {
        // 0x6d
        connection.registerPacket(PACKET_HC_ACCEPT_MAKECHAR.self, for: PACKET_HC_ACCEPT_MAKECHAR.packetType)
            .map { packet in
                CharEvents.MakeAccepted(char: packet.char)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x6e
        connection.registerPacket(PACKET_HC_REFUSE_MAKECHAR.self, for: PACKET_HC_REFUSE_MAKECHAR.packetType)
            .map { packet in
                CharEvents.MakeRefused()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x6f
        connection.registerPacket(PACKET_HC_ACCEPT_DELETECHAR.self, for: PACKET_HC_ACCEPT_DELETECHAR.packetType)
            .map { packet in
                CharEvents.DeleteAccepted()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x70
        connection.registerPacket(PACKET_HC_REFUSE_DELETECHAR.self, for: PACKET_HC_REFUSE_DELETECHAR.packetType)
            .map { packet in
                CharEvents.DeleteRefused(errorCode: UInt32(packet.errorCode))
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x82a
        connection.registerPacket(PACKET_HC_DELETE_CHAR.self, for: PACKET_HC_DELETE_CHAR.packetType)
            .map { packet in
                if packet.result == 1 {
                    CharEvents.DeleteAccepted()
                } else {
                    CharEvents.DeleteRefused(errorCode: packet.result)
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x82c
        connection.registerPacket(PACKET_HC_DELETE_CHAR_CANCEL.self, for: PACKET_HC_DELETE_CHAR_CANCEL.packetType)
            .map { packet in
                CharEvents.DeleteCancelled()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x828
        connection.registerPacket(PACKET_HC_DELETE_CHAR_RESERVED.self, for: PACKET_HC_DELETE_CHAR_RESERVED.packetType)
            .map { packet in
                CharEvents.DeletionDateResponse(deletionDate: packet.deletionDate)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    public func subscribe<E>(to event: E.Type, _ handler: @escaping (E) -> Void) -> any Cancellable where E: Event {
        let cancellable = eventSubject
            .compactMap { event in
                event as? E
            }
            .sink { event in
                handler(event)
            }
        return cancellable
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
        let accountID = state.accountID

        Timer.publish(every: 12, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CZ_PING()
                packet.accountID = accountID

                self?.connection.sendPacket(packet)
            }
            .store(in: &subscriptions)
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
