//
//  LoginClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import Combine
import Foundation

final public class LoginClient {
    private let connection: ClientConnection

    private let eventSubject = PassthroughSubject<any Event, Never>()
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        connection = ClientConnection(port: 6900)

        connection.errorHandler = { [weak self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self?.eventSubject.send(event)
        }

        // 0x69, 0xac4
        connection.registerPacket(PACKET_AC_ACCEPT_LOGIN.self)
            .map { packet in
                let event = LoginEvents.Accepted(
                    accountID: packet.accountID,
                    loginID1: packet.loginID1,
                    loginID2: packet.loginID2,
                    sex: packet.sex,
                    charServers: packet.charServers
                )
                return event
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x6a, 0x83e
        connection.registerPacket(PACKET_AC_REFUSE_LOGIN.self)
            .map { packet in
                LoginEvents.Refused(errorCode: packet.errorCode, unblockTime: packet.unblockTime)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x81
        connection.registerPacket(PACKET_SC_NOTIFY_BAN.self)
            .map { packet in
                AuthenticationEvents.Banned(errorCode: packet.errorCode)
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

    /// Login.
    ///
    /// Send ``PACKET_CA_LOGIN``
    ///
    /// Receive ``PACKET_AC_ACCEPT_LOGIN`` or
    ///         ``PACKET_AC_REFUSE_LOGIN`` or
    ///         ``PACKET_SC_NOTIFY_BAN``
    public func login(username: String, password: String) {
        var packet = PACKET_CA_LOGIN()
        packet.username = username
        packet.password = password

        connection.sendPacket(packet)

        connection.receivePacket()
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CA_CONNECT_INFO_CHANGED`` every 10 seconds.
    public func keepAlive(username: String) {
        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CA_CONNECT_INFO_CHANGED()
                packet.name = username

                self?.connection.sendPacket(packet)
            }
            .store(in: &subscriptions)
    }
}
