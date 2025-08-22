//
//  CharSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/8.
//

import AsyncAlgorithms
import Combine
import Foundation
import ROPackets

final public class CharSession: SessionProtocol, @unchecked Sendable {
    public private(set) var account: AccountInfo

    let client: Client
    let eventSubject = PassthroughSubject<any Event, Never>()

    private var timerTask: Task<Void, Never>?

    public var eventPublisher: AnyPublisher<any Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public init(account: AccountInfo, charServer: CharServerInfo) {
        self.account = account
        self.client = Client(name: "Char", address: charServer.ip, port: charServer.port)
    }

    public func start() {
        var subscription = ClientSubscription()

        subscription.subscribe(to: ClientError.self) { [unowned self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self.eventSubject.send(event)
        }

        subscribeToCharServerPackets(with: &subscription)
        subscribeToCharPackets(with: &subscription)

        // 0x82d
        subscription.subscribe(to: PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.self) { packet in
        }

        // 0x8b9
        subscription.subscribe(to: PACKET_HC_SECOND_PASSWD_LOGIN.self) { packet in
        }

        // 0x9a0
        subscription.subscribe(to: PACKET_HC_CHARLIST_NOTIFY.self) { packet in
        }

        // 0x20d
        subscription.subscribe(to: PACKET_HC_BLOCK_CHARACTER.self) { packet in
        }

        // See `chclif_send_auth_result`
        subscription.subscribe(to: PACKET_SC_NOTIFY_BAN.self) { [unowned self] packet in
            let message = BannedMessage(packet: packet)
            let event = AuthenticationEvents.Banned(message: message)
            self.postEvent(event)
        }

        client.connect(with: subscription)

        enter()

        keepAlive()
    }

    public func stop() {
        client.disconnect()

        timerTask?.cancel()
        timerTask = nil
    }

    private func subscribeToCharServerPackets(with subscription: inout ClientSubscription) {
        // 0x6b
        subscription.subscribe(to: PACKET_HC_ACCEPT_ENTER_NEO_UNION.self) { [unowned self] packet in
            let event = CharServerEvents.Accepted(chars: packet.chars)
            self.postEvent(event)
        }

        // 0x6c
        subscription.subscribe(to: PACKET_HC_REFUSE_ENTER.self) { [unowned self] packet in
            let event = CharServerEvents.Refused()
            self.postEvent(event)
        }

        // 0x71, 0xac5
        subscription.subscribe(to: PACKET_HC_NOTIFY_ZONESVR.self) { [unowned self] packet in
            let event = CharServerEvents.NotifyMapServer(
                charID: packet.charID,
                mapName: packet.mapName,
                mapServer: packet.mapServer
            )
            self.postEvent(event)
        }

        // 0x840
        subscription.subscribe(to: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self) { [unowned self] packet in
            let event = CharServerEvents.NotifyAccessibleMaps(
                accessibleMaps: packet.maps.map(AccessibleMapInfo.init)
            )
            self.postEvent(event)
        }
    }

    private func subscribeToCharPackets(with subscription: inout ClientSubscription) {
        // 0x6d
        subscription.subscribe(to: PACKET_HC_ACCEPT_MAKECHAR.self) { [unowned self] packet in
            let event = CharEvents.MakeAccepted(char: packet.char)
            self.postEvent(event)
        }

        // 0x6e
        subscription.subscribe(to: PACKET_HC_REFUSE_MAKECHAR.self) { [unowned self] packet in
            let event = CharEvents.MakeRefused()
            self.postEvent(event)
        }

        // 0x6f
        subscription.subscribe(to: PACKET_HC_ACCEPT_DELETECHAR.self) { [unowned self] packet in
            let event = CharEvents.DeleteAccepted()
            self.postEvent(event)
        }

        // 0x70
        subscription.subscribe(to: PACKET_HC_REFUSE_DELETECHAR.self) { [unowned self] packet in
            let event = CharEvents.DeleteRefused(message: "")
            self.postEvent(event)
        }

        // 0x82a
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR.self) { [unowned self] packet in
            if packet.result == 1 {
                let event = CharEvents.DeleteAccepted()
                self.postEvent(event)
            } else {
                let event = CharEvents.DeleteRefused(message: "")
                self.postEvent(event)
            }
        }

        // 0x82c
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR_CANCEL.self) { [unowned self] packet in
            let event = CharEvents.DeleteCancelled()
            self.postEvent(event)
        }

        // 0x828
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR_RESERVED.self) { [unowned self] packet in
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
    private func enter() {
        var packet = PACKET_CH_ENTER()
        packet.accountID = account.accountID
        packet.loginID1 = account.loginID1
        packet.loginID2 = account.loginID2
        packet.clientType = account.langType
        packet.sex = account.sex

        client.sendPacket(packet)

        client.receiveDataAndPacket(count: 4) { data in
            let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
            self.account.update(accountID: accountID)
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_PING`` every 12 seconds.
    private func keepAlive() {
        let timer = AsyncTimerSequence(interval: .seconds(12), clock: .continuous)

        let accountID = account.accountID
        let client = client

        timerTask = Task {
            for await _ in timer {
                var packet = PACKET_CZ_PING()
                packet.accountID = accountID

                client.sendPacket(packet)
            }
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

    private func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }
}
