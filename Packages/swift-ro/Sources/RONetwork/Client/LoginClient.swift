//
//  LoginClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import Combine
import Foundation
import ROGenerated

final public class LoginClient: ClientBase {
    private var timerSubscription: AnyCancellable?

    public init() {
        super.init(port: 6900)

        // 0x69, 0xac4
        registerPacket(PACKET_AC_ACCEPT_LOGIN.self, for: PACKET_AC_ACCEPT_LOGIN.packetType) { [unowned self] packet in
            let event = LoginEvents.Accepted(packet: packet)
            self.postEvent(event)
        }

        // 0x6a, 0x83e
        registerPacket(PACKET_AC_REFUSE_LOGIN.self, for: PACKET_AC_REFUSE_LOGIN.packetType) { [unowned self] packet in
            let event = LoginEvents.Refused(packet: packet)
            self.postEvent(event)
        }

        // See `logclif_sent_auth_result`
        registerPacket(PACKET_SC_NOTIFY_BAN.self, for: HEADER_SC_NOTIFY_BAN) { [unowned self] packet in
            let event = AuthenticationEvents.Banned(packet: packet)
            self.postEvent(event)
        }
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

        sendPacket(packet)

        receivePacket()
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CA_CONNECT_INFO_CHANGED`` every 10 seconds.
    public func keepAlive(username: String) {
        timerSubscription = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CA_CONNECT_INFO_CHANGED()
                packet.name = username

                self?.sendPacket(packet)
            }
    }
}
