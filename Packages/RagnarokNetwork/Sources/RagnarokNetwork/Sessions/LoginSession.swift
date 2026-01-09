//
//  LoginSession.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/3/27.
//

import Combine
import Foundation
import RagnarokModels
import RagnarokPackets

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

    private var username: String?

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
                account: AccountInfo(from: packet),
                charServers: packet.char_servers.map { CharServerInfo(from: $0) }
            )
            self.postEvent(event)

            self.keepAlive()
        }

        // See `logclif_auth_failed`
        subscription.subscribe(to: PACKET_AC_REFUSE_LOGIN.self) { [unowned self] packet in
            let message = LoginRefusedMessage(from: packet)
            let event = LoginSession.Event.loginRefused(message: message)
            self.postEvent(event)
        }

        // See `logclif_sent_auth_result`
        subscription.subscribe(to: PACKET_SC_NOTIFY_BAN.self) { [unowned self] packet in
            let message = BannedMessage(from: packet)
            let event = LoginSession.Event.authenticationBanned(message: message)
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
        self.username = username

        // See `logclif_parse_reqauth_raw`
        let packet = PacketFactory.CA_LOGIN(username: username, password: password)
        client.sendPacket(packet)

        client.receivePacket()
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CA_CONNECT_INFO_CHANGED`` every 10 seconds.
    private func keepAlive() {
        let client = client

        timerTask = Task {
            do {
                while !Task.isCancelled {
                    try await Task.sleep(for: .seconds(10))

                    let packet = PacketFactory.CA_CONNECT_INFO_CHANGED(username: username ?? "")
                    client.sendPacket(packet)
                }
            } catch {
                logger.warning("\(error)")
            }
        }
    }

    private func postEvent(_ event: LoginSession.Event) {
        eventSubject.send(event)
    }
}
