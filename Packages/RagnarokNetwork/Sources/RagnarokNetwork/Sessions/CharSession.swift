//
//  CharSession.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/8/8.
//

import AsyncAlgorithms
import Combine
import Foundation
import RagnarokPackets

final public class CharSession: SessionProtocol, @unchecked Sendable {
    public enum Event: Sendable {
        // Char server events
        case charServerAccepted(characters: [CharacterInfo])
        case charServerRefused
        case charServerNotifiedMapServer(charID: UInt32, mapName: String, mapServer: MapServerInfo)
        case charServerNotifiedAccessibleMaps(accessibleMaps: [AccessibleMapInfo])

        // Character events
        case makeCharacterAccepted(character: CharacterInfo)
        case makeCharacterRefused
        case deleteCharacterAccepted
        case deleteCharacterRefused
        case deleteCharacterCancelled
        case deleteCharacterReserved(deletionDate: UInt32)

        // Error events
        case authenticationBanned(message: BannedMessage)
        case errorOccurred(error: any Error)
    }

    public private(set) var account: AccountInfo

    let client: Client
    let eventSubject = PassthroughSubject<CharSession.Event, Never>()

    public var eventPublisher: AnyPublisher<CharSession.Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var timerTask: Task<Void, Never>?

    public init(account: AccountInfo, charServer: CharServerInfo) {
        self.account = account
        self.client = Client(name: "Char", address: charServer.ip, port: charServer.port)
    }

    public func start() {
        var subscription = ClientSubscription()

        subscription.subscribe(to: ClientError.self) { [unowned self] error in
            let event = CharSession.Event.errorOccurred(error: error)
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
            let event = CharSession.Event.authenticationBanned(message: message)
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
            let characters = packet.chars.map(CharacterInfo.init(from:))
            let event = CharSession.Event.charServerAccepted(characters: characters)
            self.postEvent(event)
        }

        // 0x6c
        subscription.subscribe(to: PACKET_HC_REFUSE_ENTER.self) { [unowned self] packet in
            let event = CharSession.Event.charServerRefused
            self.postEvent(event)
        }

        // 0x71, 0xac5
        subscription.subscribe(to: PACKET_HC_NOTIFY_ZONESVR.self) { [unowned self] packet in
            let event = CharSession.Event.charServerNotifiedMapServer(
                charID: packet.charID,
                mapName: packet.mapName,
                mapServer: MapServerInfo(from: packet)
            )
            self.postEvent(event)
        }

        // 0x840
        subscription.subscribe(to: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self) { [unowned self] packet in
            let event = CharSession.Event.charServerNotifiedAccessibleMaps(
                accessibleMaps: packet.maps.map(AccessibleMapInfo.init)
            )
            self.postEvent(event)
        }
    }

    private func subscribeToCharPackets(with subscription: inout ClientSubscription) {
        // 0x6d
        subscription.subscribe(to: PACKET_HC_ACCEPT_MAKECHAR.self) { [unowned self] packet in
            let character = CharacterInfo(from: packet.char)
            let event = CharSession.Event.makeCharacterAccepted(character: character)
            self.postEvent(event)
        }

        // 0x6e
        subscription.subscribe(to: PACKET_HC_REFUSE_MAKECHAR.self) { [unowned self] packet in
            let event = CharSession.Event.makeCharacterRefused
            self.postEvent(event)
        }

        // 0x6f
        subscription.subscribe(to: PACKET_HC_ACCEPT_DELETECHAR.self) { [unowned self] packet in
            let event = CharSession.Event.deleteCharacterAccepted
            self.postEvent(event)
        }

        // 0x70
        subscription.subscribe(to: PACKET_HC_REFUSE_DELETECHAR.self) { [unowned self] packet in
            let event = CharSession.Event.deleteCharacterRefused
            self.postEvent(event)
        }

        // 0x82a
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR.self) { [unowned self] packet in
            if packet.result == 1 {
                let event = CharSession.Event.deleteCharacterAccepted
                self.postEvent(event)
            } else {
                let event = CharSession.Event.deleteCharacterRefused
                self.postEvent(event)
            }
        }

        // 0x82c
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR_CANCEL.self) { [unowned self] packet in
            let event = CharSession.Event.deleteCharacterCancelled
            self.postEvent(event)
        }

        // 0x828
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR_RESERVED.self) { [unowned self] packet in
            let event = CharSession.Event.deleteCharacterReserved(deletionDate: packet.deletionDate)
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
        packet.packetType = HEADER_CH_ENTER
        packet.accountID = account.accountID
        packet.loginID1 = account.loginID1
        packet.loginID2 = account.loginID2
        packet.clientType = account.langType
        packet.sex = UInt8(account.sex)

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
                packet.packetType = HEADER_CZ_PING
                packet.accountID = accountID

                client.sendPacket(packet)
            }
        }
    }

    /// Make character.
    ///
    /// Send ``PACKET_CH_MAKE_CHAR``
    ///
    /// Receive ``PACKET_HC_ACCEPT_MAKECHAR`` or
    ///         ``PACKET_HC_REFUSE_MAKECHAR``
    public func makeCharacter(character: CharacterInfo) {
        var packet = PACKET_CH_MAKE_CHAR()
        packet.packetType = HEADER_CH_MAKE_CHAR
        packet.name = character.name
        packet.str = UInt8(character.str)
        packet.agi = UInt8(character.agi)
        packet.vit = UInt8(character.vit)
        packet.int = UInt8(character.int)
        packet.dex = UInt8(character.dex)
        packet.luk = UInt8(character.luk)
        packet.slot = UInt8(character.charNum)
        packet.hairColor = UInt16(character.headPalette)
        packet.hairStyle = UInt16(character.head)
        packet.job = UInt16(character.job)
        packet.sex = UInt8(character.sex)

        client.sendPacket(packet)
    }

    /// Delete character.
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
    public func deleteCharacter(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR()
        packet.packetType = HEADER_CH_DELETE_CHAR
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
        packet.packetType = HEADER_CH_DELETE_CHAR_RESERVED
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
        packet.packetType = HEADER_CH_DELETE_CHAR_CANCEL
        packet.charID = charID

        client.sendPacket(packet)
    }

    /// Select character.
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
    public func selectCharacter(slot: Int) {
        var packet = PACKET_CH_SELECT_CHAR()
        packet.packetType = HEADER_CH_SELECT_CHAR
        packet.slot = UInt8(slot)

        client.sendPacket(packet)
    }

    private func postEvent(_ event: CharSession.Event) {
        eventSubject.send(event)
    }
}
