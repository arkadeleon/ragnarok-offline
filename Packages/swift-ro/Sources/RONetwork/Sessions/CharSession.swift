//
//  CharSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/8.
//

import Combine
import Foundation
import ROGenerated

final public class CharSession: SessionProtocol {
    public let storage: SessionStorage

    let client: Client
    let eventSubject = PassthroughSubject<any Event, Never>()

    private var timerSubscription: AnyCancellable?

    public var eventPublisher: AnyPublisher<any Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public init(storage: SessionStorage, charServer: CharServerInfo) {
        self.storage = storage

        self.client = Client(address: charServer.ip, port: charServer.port)

        client.errorHandler = { [unowned self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self.eventSubject.send(event)
        }

        registerCharServerPackets()
        registerCharPackets()

        // 0x82d
        client.registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.self, for: PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.packetType) { packet in
        }

        // 0x8b9
        client.registerPacket(PACKET_HC_SECOND_PASSWD_LOGIN.self, for: PACKET_HC_SECOND_PASSWD_LOGIN.packetType) { packet in
        }

        // 0x9a0
        client.registerPacket(PACKET_HC_CHARLIST_NOTIFY.self, for: PACKET_HC_CHARLIST_NOTIFY.packetType) { packet in
        }

        // 0x20d
        client.registerPacket(PACKET_HC_BLOCK_CHARACTER.self, for: PACKET_HC_BLOCK_CHARACTER.packetType) { packet in
        }

        // See `chclif_send_auth_result`
        client.registerPacket(PACKET_SC_NOTIFY_BAN.self, for: HEADER_SC_NOTIFY_BAN) { [unowned self] packet in
            let event = await AuthenticationEvents.Banned(packet: packet)
            self.postEvent(event)
        }
    }

    private func registerCharServerPackets() {
        // 0x6b
        client.registerPacket(PACKET_HC_ACCEPT_ENTER_NEO_UNION.self, for: PACKET_HC_ACCEPT_ENTER_NEO_UNION.packetType) { [unowned self] packet in
            await self.storage.updateChars(packet.chars)

            let event = CharServerEvents.Accepted(packet: packet)
            self.postEvent(event)
        }

        // 0x6c
        client.registerPacket(PACKET_HC_REFUSE_ENTER.self, for: PACKET_HC_REFUSE_ENTER.packetType) { [unowned self] packet in
            let event = CharServerEvents.Refused()
            self.postEvent(event)
        }

        // 0x71, 0xac5
        client.registerPacket(PACKET_HC_NOTIFY_ZONESVR.self, for: PACKET_HC_NOTIFY_ZONESVR.packetType) { [unowned self] packet in
            await self.storage.updateMapServer(with: packet)

            let event = CharServerEvents.NotifyMapServer(packet: packet)
            self.postEvent(event)
        }

        // 0x840
        client.registerPacket(PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self, for: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.packetType) { [unowned self] packet in
            let event = CharServerEvents.NotifyAccessibleMaps(packet: packet)
            self.postEvent(event)
        }
    }

    private func registerCharPackets() {
        // 0x6d
        client.registerPacket(PACKET_HC_ACCEPT_MAKECHAR.self, for: PACKET_HC_ACCEPT_MAKECHAR.packetType) { [unowned self] packet in
            await self.storage.addChar(packet.char)

            let event = CharEvents.MakeAccepted(packet: packet)
            self.postEvent(event)
        }

        // 0x6e
        client.registerPacket(PACKET_HC_REFUSE_MAKECHAR.self, for: PACKET_HC_REFUSE_MAKECHAR.packetType) { [unowned self] packet in
            let event = CharEvents.MakeRefused()
            self.postEvent(event)
        }

        // 0x6f
        client.registerPacket(PACKET_HC_ACCEPT_DELETECHAR.self, for: PACKET_HC_ACCEPT_DELETECHAR.packetType) { [unowned self] packet in
            let event = CharEvents.DeleteAccepted()
            self.postEvent(event)
        }

        // 0x70
        client.registerPacket(PACKET_HC_REFUSE_DELETECHAR.self, for: PACKET_HC_REFUSE_DELETECHAR.packetType) { [unowned self] packet in
            let event = CharEvents.DeleteRefused(packet: packet)
            self.postEvent(event)
        }

        // 0x82a
        client.registerPacket(PACKET_HC_DELETE_CHAR.self, for: PACKET_HC_DELETE_CHAR.packetType) { [unowned self] packet in
            if packet.result == 1 {
                let event = CharEvents.DeleteAccepted()
                self.postEvent(event)
            } else {
                let event = CharEvents.DeleteRefused(packet: packet)
                self.postEvent(event)
            }
        }

        // 0x82c
        client.registerPacket(PACKET_HC_DELETE_CHAR_CANCEL.self, for: PACKET_HC_DELETE_CHAR_CANCEL.packetType) { [unowned self] packet in
            let event = CharEvents.DeleteCancelled()
            self.postEvent(event)
        }

        // 0x828
        client.registerPacket(PACKET_HC_DELETE_CHAR_RESERVED.self, for: PACKET_HC_DELETE_CHAR_RESERVED.packetType) { [unowned self] packet in
            let event = CharEvents.DeletionDateResponse(packet: packet)
            self.postEvent(event)
        }
    }

    private func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }

    public func start() {
        client.connect()

        Task {
            await enter()

            await keepAlive()
        }
    }

    public func stop() {
        client.disconnect()

        timerSubscription = nil
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
    private func enter() async {
        var packet = PACKET_CH_ENTER()
        packet.accountID = await storage.accountID
        packet.loginID1 = await storage.loginID1
        packet.loginID2 = await storage.loginID2
        packet.clientType = storage.langType
        packet.sex = await storage.sex

        client.sendPacket(packet)

        client.receiveDataAndPacket(count: 4) { data in
            Task {
                let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
                await self.storage.updateAccountID(accountID)
            }
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_PING`` every 12 seconds.
    private func keepAlive() async {
        let accountID = await storage.accountID

        timerSubscription = Timer.publish(every: 12, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CZ_PING()
                packet.accountID = accountID

                self?.client.sendPacket(packet)
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

        client.sendPacket(packet)
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

        client.sendPacket(packet)
    }

    /// Request deletion date.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_RESERVED``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_RESERVED``
    public func requestDeletionDate(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_RESERVED()
        packet.charID = charID

        client.sendPacket(packet)
    }

    /// Cancel delete.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_CANCEL``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_CANCEL``
    public func cancelDelete(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_CANCEL()
        packet.charID = charID

        client.sendPacket(packet)
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

        client.sendPacket(packet)
    }
}
