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
    let client: Client
    let eventSubject = PassthroughSubject<any Event, Never>()

    private var timerTask: Task<Void, Never>?

    public var eventPublisher: AnyPublisher<any Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public init(address: String, port: UInt16) {
        self.client = Client(name: "Login", address: address, port: port)
    }

    public func start() {
        var subscription = ClientSubscription()

        subscription.subscribe(to: ClientError.self) { [unowned self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self.eventSubject.send(event)
        }

        // See `logclif_auth_ok`
        subscription.subscribe(to: PACKET_AC_ACCEPT_LOGIN.self) { [unowned self] packet in
            let event = LoginEvents.Accepted(
                account: AccountInfo(packet: packet),
                charServers: packet.char_servers.map(CharServerInfo.init)
            )
            self.postEvent(event)
        }

        // See `logclif_auth_failed`
        subscription.subscribe(to: PACKET_AC_REFUSE_LOGIN.self) { [unowned self] packet in
            let message = LoginRefusedMessage(packet: packet)
            let event = LoginEvents.Refused(message: message)
            self.postEvent(event)
        }

        // See `logclif_sent_auth_result`
        subscription.subscribe(to: PACKET_SC_NOTIFY_BAN.self) { [unowned self] packet in
            let message = BannedMessage(packet: packet)
            let event = AuthenticationEvents.Banned(message: message)
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

    private func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }
}
