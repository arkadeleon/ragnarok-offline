//
//  LoginSession.swift
//  NetworkClient
//
//  Created by Leon Li on 2024/3/27.
//

import AsyncAlgorithms
import Combine
import Foundation
import NetworkPackets

final public class LoginSession: SessionProtocol, @unchecked Sendable {
    public enum Event: Sendable {
        // Login events
        case loginAccepted(account: AccountInfo, charServers: [CharServerInfo])
        case loginRefused(message: LoginRefusedMessage)

        // Error events
        case authenticationBanned(message: BannedMessage)
        case errorOccurred(error: any Error)
    }

    let client: Client
    let eventSubject = PassthroughSubject<LoginSession.Event, Never>()

    public var eventPublisher: AnyPublisher<LoginSession.Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var timerTask: Task<Void, Never>?

    public init(address: String, port: UInt16) {
        self.client = Client(name: "Login", address: address, port: port)
    }

    public func start() {
        var subscription = ClientSubscription()

        subscription.subscribe(to: ClientError.self) { [unowned self] error in
            let event = LoginSession.Event.errorOccurred(error: error)
            self.eventSubject.send(event)
        }

        // See `logclif_auth_ok`
        subscription.subscribe(to: PACKET_AC_ACCEPT_LOGIN.self) { [unowned self] packet in
            let event = LoginSession.Event.loginAccepted(
                account: AccountInfo(packet: packet),
                charServers: packet.char_servers.map(CharServerInfo.init)
            )
            self.postEvent(event)
        }

        // See `logclif_auth_failed`
        subscription.subscribe(to: PACKET_AC_REFUSE_LOGIN.self) { [unowned self] packet in
            let message = LoginRefusedMessage(packet: packet)
            let event = LoginSession.Event.loginRefused(message: message)
            self.postEvent(event)
        }

        // See `logclif_sent_auth_result`
        subscription.subscribe(to: PACKET_SC_NOTIFY_BAN.self) { [unowned self] packet in
            let message = BannedMessage(packet: packet)
            let event = LoginSession.Event.authenticationBanned(message: message)
            self.postEvent(event)
        }

        client.connect(with: subscription)
    }

    public func stop() {
        client.disconnect()

        timerTask?.cancel()
        timerTask = nil
    }

    /// Login.
    ///
    /// Send ``PACKET_CA_LOGIN``
    ///
    /// Receive ``PACKET_AC_ACCEPT_LOGIN`` or
    ///         ``PACKET_AC_REFUSE_LOGIN`` or
    ///         ``PACKET_SC_NOTIFY_BAN``
    public func login(username: String, password: String) {
        // See `logclif_parse_reqauth_raw`
        var packet = PACKET_CA_LOGIN()
        packet.packetType = HEADER_CA_LOGIN
        packet.version = 0
        packet.username = username
        packet.password = password
        packet.clienttype = 0

        client.sendPacket(packet)

        client.receivePacket()
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CA_CONNECT_INFO_CHANGED`` every 10 seconds.
    public func keepAlive(username: String) {
        let timer = AsyncTimerSequence(interval: .seconds(10), clock: .continuous)

        let client = client

        timerTask = Task {
            for await _ in timer {
                // See `logclif_parse_keepalive`
                var packet = PACKET_CA_CONNECT_INFO_CHANGED()
                packet.packetType = HEADER_CA_CONNECT_INFO_CHANGED
                packet.name = username

                client.sendPacket(packet)
            }
        }
    }

    private func postEvent(_ event: LoginSession.Event) {
        eventSubject.send(event)
    }
}
