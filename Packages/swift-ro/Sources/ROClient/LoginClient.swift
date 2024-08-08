//
//  LoginClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import Foundation
import Network
import RONetwork
import ROResources

/// Login client.
///
/// Sendable packets:
/// - ``PACKET_CA_LOGIN``
/// - ``PACKET_CA_CONNECT_INFO_CHANGED``
/// - ``PACKET_CA_EXE_HASHCHECK``
///
/// Receivable packets:
/// - ``PACKET_AC_ACCEPT_LOGIN``
/// - ``PACKET_AC_REFUSE_LOGIN``
/// - ``PACKET_SC_NOTIFY_BAN``
public class LoginClient {
    public var onAcceptLogin: ((PACKET_AC_ACCEPT_LOGIN) -> Void)?
    public var onRefuseLogin: ((String) -> Void)?
    public var onNotifyBan: ((String) -> Void)?
    public var onError: ((any Error) -> Void)?

    private let encoder: PacketEncoder
    private let decoder: PacketDecoder

    private let connection: NWConnection

    public init() {
        encoder = PacketEncoder()
        decoder = PacketDecoder()

        connection = NWConnection(host: .ipv4(.loopback), port: 6900, using: .tcp)
    }

    public func connect() {
        let queue = DispatchQueue(label: "")
        connection.start(queue: queue)

        connection.stateUpdateHandler = { state in
            print(state)
        }

        receiveNext()
    }

    public func login(username: String, password: String) throws {
        var login = PACKET_CA_LOGIN()
        login.username = username
        login.password = password

        let data = try encoder.encode(login)
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error {
                self.onError?(error)
            }
        }))
    }

    public func keepAlive(username: String) {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            var packet = PACKET_CA_CONNECT_INFO_CHANGED()
            packet.name = username

            let data = try? self.encoder.encode(packet)
            self.connection.send(content: data, completion: .contentProcessed({ error in
                if let error {
                    self.onError?(error)
                }
            }))
        }
    }

    private func receiveNext() {
        connection.receive(minimumIncompleteLength: 2, maximumLength: 1000) { [weak self] content, contentContext, isComplete, error in
            if let content, let self {
                do {
                    let packet = try decoder.decode(from: content)
                    switch packet {
                    case let acceptLoginPacket as PACKET_AC_ACCEPT_LOGIN:
                        onAcceptLogin?(acceptLoginPacket)
                    case let refuseLoginPacket as PACKET_AC_REFUSE_LOGIN:
                        onReceiveRefuseLoginPacket(refuseLoginPacket)
                    case let notifyBanPacket as PACKET_SC_NOTIFY_BAN:
                        onReceiveNotifyBanPacket(notifyBanPacket)
                    default:
                        onError?(PacketDecodingError.unknownPacket(packet.packetType))
                    }
                } catch {
                    onError?(error)
                }
            }
            if let error {
                self?.onError?(error)
            }

            self?.receiveNext()
        }
    }

    private func onReceiveRefuseLoginPacket(_ packet: PACKET_AC_REFUSE_LOGIN) {
        let messageCode = switch packet.errorCode {
        case   0: 6     // Unregistered ID
        case   1: 7     // Incorrect Password
        case   2: 8     // This ID is expired
        case   3: 3     // Rejected from Server
        case   4: 266   // Checked: 'Login is currently unavailable. Please try again shortly.'- 2br
        case   5: 310   // Your Game's EXE file is not the latest version
        case   6: 449   // Your are Prohibited to log in until %s
        case   7: 264   // Server is jammed due to over populated
        case   8: 681   // Checked: 'This account can't connect the Sakray server.'
        case   9: 703   // 9 = MSI_REFUSE_BAN_BY_DBA
        case  10: 704   // 10 = MSI_REFUSE_EMAIL_NOT_CONFIRMED
        case  11: 705   // 11 = MSI_REFUSE_BAN_BY_GM
        case  12: 706   // 12 = MSI_REFUSE_TEMP_BAN_FOR_DBWORK
        case  13: 707   // 13 = MSI_REFUSE_SELF_LOCK
        case  14: 708   // 14 = MSI_REFUSE_NOT_PERMITTED_GROUP
        case  15: 709   // 15 = MSI_REFUSE_NOT_PERMITTED_GROUP
        case  99: 368   // 99 = This ID has been totally erased
        case 100: 809   // 100 = Login information remains at %s
        case 101: 810   // 101 = Account has been locked for a hacking investigation. Please contact the GM Team for more information
        case 102: 811   // 102 = This account has been temporarily prohibited from login due to a bug-related investigation
        case 103: 859   // 103 = This character is being deleted. Login is temporarily unavailable for the time being
        case 104: 860   // 104 = This character is being deleted. Login is temporarily unavailable for the time being
        default : 9
        }

        Task {
            var message = await MessageLocalization.shared.localizedMessage(at: messageCode)
            message = message.replacingOccurrences(of: "%s", with: packet.blockDate)
            onRefuseLogin?(message)
        }
    }

    private func onReceiveNotifyBanPacket(_ packet: PACKET_SC_NOTIFY_BAN) {
        let messageCode = switch packet.errorCode {
        case   0: 3     // Server closed
        case   1: 4     // Server closed
        case   2: 5     // Someone has already logged in with this id
        case   3: 9     // Sync error ?
        case   4: 439   // Server is jammed due to overpopulation.
        case   5: 305   // You are underaged and cannot join this server.
        case   6: 764   // Trial players can't connect Pay to Play Server. (761)
        case   8: 440   // Server still recognizes your last login
        case   9: 529   // IP capacity of this Internet Cafe is full. Would you like to pay the personal base?
        case  10: 530   // You are out of available paid playing time. Game will be shut down automatically. (528)
        case  15: 579   // You have been forced to disconnect by the Game Master Team
        case 101: 810   // Account has been locked for a hacking investigation.
        case 102: 1179  // More than 10 connections sharing the same IP have logged into the game for an hour. (1176)
        default : 3
        }

        Task {
            let message = await MessageLocalization.shared.localizedMessage(at: messageCode)
            onNotifyBan?(message)
        }
    }
}
