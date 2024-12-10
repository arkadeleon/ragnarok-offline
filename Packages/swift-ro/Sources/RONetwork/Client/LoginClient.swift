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

        // See `logclif_auth_ok`
        registerPacket(PACKET_AC_ACCEPT_LOGIN.self, for: HEADER_AC_ACCEPT_LOGIN) { [unowned self] packet in
            let event = LoginEvents.Accepted(packet: packet)
            self.postEvent(event)
        }

        // See `logclif_auth_failed`
        registerPacket(PACKET_AC_REFUSE_LOGIN.self, for: HEADER_AC_REFUSE_LOGIN) { [unowned self] packet in
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
        // See `logclif_parse_reqauth_raw`
        var packet = PACKET_CA_LOGIN()
        packet.packetType = HEADER_CA_LOGIN
        packet.version = 0
        packet.username = username
        packet.password = password
        packet.clienttype = 0

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
                // See `logclif_parse_keepalive`
                var packet = PACKET_CA_CONNECT_INFO_CHANGED()
                packet.packetType = HEADER_CA_CONNECT_INFO_CHANGED
                packet.name = username

                self?.sendPacket(packet)
            }
    }
}
