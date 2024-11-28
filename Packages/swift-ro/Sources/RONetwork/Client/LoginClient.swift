//
//  LoginClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import Combine
import Foundation

final public class LoginClient: ClientBase {
    private var timerSubscription: AnyCancellable?

    public init() {
        super.init(port: 6900)

        // 0x69, 0xac4
        registerPacket(PACKET_AC_ACCEPT_LOGIN.self, for: PACKET_AC_ACCEPT_LOGIN.packetType) { [weak self] packet in
            let event = LoginEvents.Accepted(
                accountID: packet.accountID,
                loginID1: packet.loginID1,
                loginID2: packet.loginID2,
                sex: packet.sex,
                charServers: packet.charServers
            )
            self?.postEvent(event)
        }

        // 0x6a, 0x83e
        registerPacket(PACKET_AC_REFUSE_LOGIN.self, for: PACKET_AC_REFUSE_LOGIN.packetType) { [weak self] packet in
            let event = LoginEvents.Refused(errorCode: packet.errorCode, unblockTime: packet.unblockTime)
            self?.postEvent(event)
        }

        // 0x81
        registerPacket(PACKET_SC_NOTIFY_BAN.self, for: PACKET_SC_NOTIFY_BAN.packetType) { [weak self] packet in
            let event = AuthenticationEvents.Banned(errorCode: packet.errorCode)
            self?.postEvent(event)
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
