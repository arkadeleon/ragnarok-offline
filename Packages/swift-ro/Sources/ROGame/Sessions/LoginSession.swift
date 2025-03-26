//
//  LoginSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import Combine
import Foundation
import RONetwork

final public class LoginSession: SessionProtocol, @unchecked Sendable {
    public let storage: SessionStorage

    let client: Client
    let eventSubject = PassthroughSubject<any Event, Never>()

    private var timerSubscription: AnyCancellable?

    public var eventPublisher: AnyPublisher<any Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public init(storage: SessionStorage, address: String, port: UInt16) {
        self.storage = storage

        self.client = Client(name: "Login", address: address, port: port)

        client.subscribe(to: ClientError.self) { [unowned self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self.eventSubject.send(event)
        }

        // See `logclif_auth_ok`
        client.subscribe(to: PACKET_AC_ACCEPT_LOGIN.self) { [unowned self] packet in
            await self.storage.updateAccount(with: packet)

            let event = LoginEvents.Accepted(packet: packet)
            self.postEvent(event)
        }

        // See `logclif_auth_failed`
        client.subscribe(to: PACKET_AC_REFUSE_LOGIN.self) { [unowned self] packet in
            let event = await LoginEvents.Refused(packet: packet)
            self.postEvent(event)
        }

        // See `logclif_sent_auth_result`
        client.subscribe(to: PACKET_SC_NOTIFY_BAN.self) { [unowned self] packet in
            let event = await AuthenticationEvents.Banned(packet: packet)
            self.postEvent(event)
        }
    }

    private func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }

    public func start() {
        client.connect()
    }

    public func stop() {
        client.disconnect()

        timerSubscription = nil
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
        timerSubscription = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                // See `logclif_parse_keepalive`
                var packet = PACKET_CA_CONNECT_INFO_CHANGED()
                packet.packetType = HEADER_CA_CONNECT_INFO_CHANGED
                packet.name = username

                self?.client.sendPacket(packet)
            }
    }
}
