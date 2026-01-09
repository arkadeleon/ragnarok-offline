//
//  CharSession.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/8/8.
//

import AsyncAlgorithms
import Combine
import Foundation
import RagnarokModels
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
        subscription.subscribe(to: PACKET_HC_ACCEPT_ENTER2.self) { packet in
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
            let message = BannedMessage(from: packet)
            let event = CharSession.Event.authenticationBanned(message: message)
            self.postEvent(event)
        }

        client.connect()

        let errorHandlers = subscription.errorHandlers
        let packetHandlers = subscription.packetHandlers

        Task {
            for await error in client.errorStream {
                for errorHandler in errorHandlers {
                    errorHandler(error)
                }
            }
        }

        Task {
            for await packet in client.packetStream {
                for packetHandler in packetHandlers {
                    if type(of: packet) == packetHandler.type {
                        packetHandler.handlePacket(packet)
                    }
                }
            }
        }

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
        subscription.subscribe(to: PACKET_HC_ACCEPT_ENTER.self) { [unowned self] packet in
            let characters = packet.characters.map(CharacterInfo.init(from:))
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
                charID: packet.CID,
                mapName: packet.mapname,
                mapServer: MapServerInfo(from: packet)
            )
            self.postEvent(event)
        }

        // 0x840
        subscription.subscribe(to: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self) { [unowned self] packet in
            let event = CharSession.Event.charServerNotifiedAccessibleMaps(
                accessibleMaps: packet.maps.map { AccessibleMapInfo(from: $0) }
            )
            self.postEvent(event)
        }
    }

    private func subscribeToCharPackets(with subscription: inout ClientSubscription) {
        // 0x6d
        subscription.subscribe(to: PACKET_HC_ACCEPT_MAKECHAR.self) { [unowned self] packet in
            let character = CharacterInfo(from: packet.character)
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
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR3.self) { [unowned self] packet in
            if packet.result == 1 {
                let event = CharSession.Event.deleteCharacterAccepted
                self.postEvent(event)
            } else {
                let event = CharSession.Event.deleteCharacterRefused
                self.postEvent(event)
            }
        }

        // 0x82c
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR3_CANCEL.self) { [unowned self] packet in
            let event = CharSession.Event.deleteCharacterCancelled
            self.postEvent(event)
        }

        // 0x828
        subscription.subscribe(to: PACKET_HC_DELETE_CHAR3_RESERVED.self) { [unowned self] packet in
            let event = CharSession.Event.deleteCharacterReserved(deletionDate: packet.date)
            self.postEvent(event)
        }
    }

    /// Enter.
    ///
    /// Send ``PACKET_CH_ENTER``
    ///
    /// Receive Account ID
    ///
    /// Receive ``PACKET_HC_ACCEPT_ENTER2`` +
    ///         ``PACKET_HC_ACCEPT_ENTER`` +
    ///         ``PACKET_HC_CHARLIST_NOTIFY`` +
    ///         ``PACKET_HC_BLOCK_CHARACTER`` +
    ///         ``PACKET_HC_SECOND_PASSWD_LOGIN`` or
    ///         ``PACKET_HC_REFUSE_ENTER``
    private func enter() {
        // `chclif_parse_reqtoconnect`
        let packet = PacketFactory.CH_ENTER(account: account)
        client.sendPacket(packet)

        client.receiveDataAndPacket(count: 4) { data in
            let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
            self.account.update(accountID: accountID)
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_PING`` every 12 seconds.
    private func keepAlive() {
        let timer = AsyncTimerSequence(interval: .seconds(12), clock: .continuous)

        let accountID = account.accountID
        let client = client

        timerTask = Task {
            for await _ in timer {
                let packet = PacketFactory.PING(accountID: accountID)
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
        // `chclif_parse_createnewchar`
        let packet = PacketFactory.CH_MAKE_CHAR(character: character)
        client.sendPacket(packet)
    }

    /// Delete character.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR3``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR3``
    public func deleteCharacter(charID: UInt32) {
        // `chclif_parse_char_delete2_accept`
        let packet = PacketFactory.CH_DELETE_CHAR3(charID: charID)
        client.sendPacket(packet)
    }

    /// Request deletion date.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR3_RESERVED``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR3_RESERVED``
    public func requestDeletionDate(charID: UInt32) {
        // `chclif_parse_char_delete2_req`
        var packet = PACKET_CH_DELETE_CHAR3_RESERVED()
        packet.packetType = HEADER_CH_DELETE_CHAR3_RESERVED
        packet.CID = charID

        client.sendPacket(packet)
    }

    /// Cancel delete.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR3_CANCEL``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR3_CANCEL``
    public func cancelDelete(charID: UInt32) {
        // `chclif_parse_char_delete2_cancel`
        var packet = PACKET_CH_DELETE_CHAR3_CANCEL()
        packet.packetType = HEADER_CH_DELETE_CHAR3_CANCEL
        packet.CID = charID

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
        // `chclif_parse_charselect`
        let packet = PacketFactory.CH_SELECT_CHAR(slot: slot)
        client.sendPacket(packet)
    }

    private func postEvent(_ event: CharSession.Event) {
        eventSubject.send(event)
    }
}
