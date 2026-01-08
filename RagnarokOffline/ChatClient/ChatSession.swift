//
//  ChatSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/15.
//

import Foundation
import Observation
import RagnarokLocalization
import RagnarokModels
import RagnarokNetwork
import RagnarokPackets
import RagnarokResources

@MainActor
@Observable
final class ChatSession {
    let serverAddress: String
    let serverPort: String

    let messageStringTable: MessageStringTable

    enum Phase {
        case login
        case selectCharServer
        case selectCharacter
        case map
    }

    var phase: ChatSession.Phase = .login

    var messages: [any Message] = []

    var playerPosition: SIMD2<Int>?

    var availableCommands: [CommandMessage.Command] {
        switch phase {
        case .login:
            [.login]
        case .selectCharServer:
            [.selectCharServer]
        case .selectCharacter:
            [.makeCharacter, .deleteCharacter, .selectCharacter]
        case .map:
            [.moveUp, .moveDown, .moveLeft, .moveRight]
        }
    }

    @ObservationIgnored
    private var account: AccountInfo?

    @ObservationIgnored
    private var charServers: [CharServerInfo] = []

    @ObservationIgnored
    private var characters: [CharacterInfo] = []

    @ObservationIgnored
    private var username: String?

    @ObservationIgnored
    private var loginClient: Client?
    @ObservationIgnored
    private var loginKeepaliveTask: Task<Void, Never>?

    @ObservationIgnored
    private var charClient: Client?
    @ObservationIgnored
    private var charKeepaliveTask: Task<Void, Never>?

    @ObservationIgnored
    private var mapClient: Client?
    @ObservationIgnored
    private var mapKeepaliveTask: Task<Void, Never>?

    init(serverAddress: String, serverPort: String) {
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.messageStringTable = MessageStringTable()
    }

    func sendMessage(_ content: String) {
        messages.append(.clientText(content))

        if let mapClient {
            var packet = PACKET_CZ_REQUEST_CHAT()
            packet.message = content
//            packet.message = "\(character.name) : \(content)"
            mapClient.sendPacket(packet)
        }
    }

    func sendCommand(_ command: CommandMessage.Command, parameters: [String] = []) {
        messages.append(.command(command, parameters: parameters))

        switch command {
        case .login:
            let username = parameters[0]
            let password = parameters[1]

            self.username = username

            startLoginClient()

            var packet = PACKET_CA_LOGIN()
            packet.packetType = HEADER_CA_LOGIN
            packet.version = 0
            packet.username = username
            packet.password = password
            packet.clienttype = 0
            loginClient?.sendPacket(packet)

            loginClient?.receivePacket()
        case .selectCharServer:
            guard let serverNumber = Int(parameters[0]),
                  serverNumber - 1 < charServers.count else {
                return
            }

            let charServer = charServers[serverNumber - 1]
            startCharClient(charServer)
        case .makeCharacter:
            guard let account else {
                break
            }

            var character = CharacterInfo()
            character.name = parameters[0]
            character.str = Int(parameters[1]) ?? 1
            character.agi = Int(parameters[2]) ?? 1
            character.vit = Int(parameters[3]) ?? 1
            character.int = Int(parameters[4]) ?? 1
            character.dex = Int(parameters[5]) ?? 1
            character.luk = Int(parameters[6]) ?? 1
            character.charNum = Int(parameters[7]) ?? 0

            var packet = PACKET_CH_MAKE_CHAR()
            packet.packetType = HEADER_CH_MAKE_CHAR
            packet.name = character.name
            packet.slot = UInt8(character.charNum)
            packet.hair_color = 0
            packet.hair_style = 0
            packet.job = 0
            packet.sex = UInt8(account.sex)
            charClient?.sendPacket(packet)
        case .deleteCharacter:
            break
        case .selectCharacter:
            let slot = Int(parameters[0]) ?? 0

            var packet = PACKET_CH_SELECT_CHAR()
            packet.packetType = HEADER_CH_SELECT_CHAR
            packet.slot = UInt8(slot)
            charClient?.sendPacket(packet)
        case .moveUp:
            if let position = playerPosition {
                var packet = PACKET_CZ_REQUEST_MOVE()
                packet.x = Int16(position.x)
                packet.y = Int16(position.y + 1)
                mapClient?.sendPacket(packet)
            }
        case .moveDown:
            if let position = playerPosition {
                var packet = PACKET_CZ_REQUEST_MOVE()
                packet.x = Int16(position.x)
                packet.y = Int16(position.y - 1)
                mapClient?.sendPacket(packet)
            }
        case .moveLeft:
            if let position = playerPosition {
                var packet = PACKET_CZ_REQUEST_MOVE()
                packet.x = Int16(position.x - 1)
                packet.y = Int16(position.y)
                mapClient?.sendPacket(packet)
            }
        case .moveRight:
            if let position = playerPosition {
                var packet = PACKET_CZ_REQUEST_MOVE()
                packet.x = Int16(position.x + 1)
                packet.y = Int16(position.y)
                mapClient?.sendPacket(packet)
            }
        }
    }

    // MARK: - Login Client

    private func startLoginClient() {
        guard let serverPort = UInt16(serverPort) else {
            return
        }

        let client = Client(name: "LoginClient", address: serverAddress, port: serverPort)

        Task {
            for await error in client.errorStream {
                messages.append(.serverText(error.localizedDescription))
            }
        }

        Task {
            for await packet in client.packetStream {
                handleLoginPacket(packet)
            }
        }

        client.connect()

        self.loginClient = client
    }

    private func startLoginKeepalive() {
        loginKeepaliveTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))

                guard !Task.isCancelled, let username else {
                    return
                }

                var packet = PACKET_CA_CONNECT_INFO_CHANGED()
                packet.packetType = HEADER_CA_CONNECT_INFO_CHANGED
                packet.name = username
                loginClient?.sendPacket(packet)
            }
        }
    }

    private func handleLoginPacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_AC_ACCEPT_LOGIN:
            let account = AccountInfo(from: packet)
            let charServers = packet.char_servers.map(CharServerInfo.init(from:))

            self.account = account
            self.charServers = charServers

            phase = .selectCharServer

            messages.append(.serverText("Accepted"))

            let charServersText = charServers.enumerated()
                .map {
                    "(\($0.offset + 1)) \($0.element.name)"
                }
                .joined(separator: "\n")
            messages.append(.serverText(charServersText))

            startLoginKeepalive()
        case let packet as PACKET_AC_REFUSE_LOGIN:
            let message = LoginRefusedMessage(from: packet)
            messages.append(.serverText("Refused"))

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                let text = text.replacingOccurrences(of: "%s", with: message.unblockTime)
                messages.append(.serverText(text))
            }
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            messages.append(.serverText("Banned"))

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                messages.append(.serverText(text))
            }
        default:
            break
        }
    }

    // MARK: - Char Client

    private func startCharClient(_ charServer: CharServerInfo) {
        guard let account else {
            return
        }

        // Stop login client before transitioning
        loginKeepaliveTask?.cancel()
        loginKeepaliveTask = nil

        loginClient?.disconnect()
        loginClient = nil

        let client = Client(name: "CharClient", address: charServer.ip, port: charServer.port)

        Task {
            for await error in client.errorStream {
                messages.append(.serverText(error.localizedDescription))
            }
        }

        Task {
            for await packet in client.packetStream {
                handleCharPacket(packet)
            }
        }

        client.connect()

        // Send initial PACKET_CH_ENTER
        var packet = PACKET_CH_ENTER()
        packet.packetType = HEADER_CH_ENTER
        packet.accountID = account.accountID
        packet.loginID1 = account.loginID1
        packet.loginID2 = account.loginID2
        packet.clientType = account.langType
        packet.sex = UInt8(account.sex)
        client.sendPacket(packet)

        // Receive accountID (4 bytes) and update account
        client.receiveDataAndPacket(count: 4) { [weak self] data in
            let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
            Task { @MainActor in
                self?.account?.update(accountID: accountID)
            }
        }

        // Start keepalive timer
        startCharKeepalive()

        self.charClient = client
    }

    private func startCharKeepalive() {
        guard let account else {
            return
        }

        charKeepaliveTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(12))

                guard !Task.isCancelled else {
                    return
                }

                var packet = PACKET_PING()
                packet.packetType = HEADER_PING
                packet.AID = account.accountID
                charClient?.sendPacket(packet)
            }
        }
    }

    private func handleCharPacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_HC_ACCEPT_ENTER:
            let characters = packet.characters.map(CharacterInfo.init(from:))
            self.characters = characters

            phase = .selectCharacter

            messages.append(.serverText("Accepted"))

            for character in characters {
                let message = """
                Char ID: \(character.charID)
                Name: \(character.name)
                Str: \(character.str)
                Agi: \(character.agi)
                Vit: \(character.vit)
                Int: \(character.int)
                Dex: \(character.dex)
                Luk: \(character.luk)
                Slot: \(character.charNum)
                """
                messages.append(.serverText(message))
            }
        case _ as PACKET_HC_REFUSE_ENTER:
            messages.append(.serverText("Refused"))
        case let packet as PACKET_HC_NOTIFY_ZONESVR:
            let mapServer = MapServerInfo(from: packet)
            let mapName = packet.mapname
            let charID = packet.CID

            phase = .map
            messages.append(.serverText("Entered map: \(mapName)"))

            startMapClient(charID: charID, mapName: mapName, mapServer: mapServer)
        case _ as PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME:
            break
        case _ as PACKET_HC_ACCEPT_MAKECHAR:
            messages.append(.serverText("Accepted"))
        case _ as PACKET_HC_REFUSE_MAKECHAR:
            messages.append(.serverText("Refused"))
        case _ as PACKET_HC_ACCEPT_DELETECHAR:
            break
        case _ as PACKET_HC_REFUSE_DELETECHAR:
            break
        case _ as PACKET_HC_DELETE_CHAR3:
            break
        case _ as PACKET_HC_DELETE_CHAR3_CANCEL:
            break
        case _ as PACKET_HC_DELETE_CHAR3_RESERVED:
            break
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            messages.append(.serverText("Banned"))

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                messages.append(.serverText(text))
            }
        default:
            break
        }
    }

    // MARK: - Map Client

    private func startMapClient(charID: UInt32, mapName: String, mapServer: MapServerInfo) {
        guard let account,
              let character = characters.first(where: { $0.charID == charID }) else {
            return
        }

        // Stop char client before transitioning
        charKeepaliveTask?.cancel()
        charKeepaliveTask = nil

        charClient?.disconnect()
        charClient = nil

        let client = Client(name: "MapClient", address: mapServer.ip, port: mapServer.port)

        Task {
            for await error in client.errorStream {
                messages.append(.serverText(error.localizedDescription))
            }
        }

        Task {
            for await packet in client.packetStream {
                handleMapPacket(packet)
            }
        }

        client.connect()

        // Send initial PACKET_CZ_ENTER
        var packet = PACKET_CZ_ENTER()
        packet.accountID = account.accountID
        packet.charID = character.charID
        packet.loginID1 = account.loginID1
        packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
        packet.sex = UInt8(account.sex)
        client.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            client.receiveDataAndPacket(count: 4) { [weak self] data in
                let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
                Task { @MainActor in
                    self?.account?.update(accountID: accountID)
                }
            }
        } else {
            client.receivePacket()
        }

        // Start keepalive timer
        startMapKeepalive()

        self.mapClient = client
    }

    private func startMapKeepalive() {
        let startTime = Date.now

        mapKeepaliveTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))

                guard !Task.isCancelled else {
                    return
                }

                var packet = PACKET_CZ_REQUEST_TIME()
                packet.clientTime = UInt32(Date.now.timeIntervalSince(startTime))
                mapClient?.sendPacket(packet)
            }
        }
    }

    private func handleMapPacket(_ packet: any DecodablePacket) {
        switch packet {
        case _ as PACKET_ZC_ACCEPT_ENTER:
            break
        case let packet as PACKET_ZC_NPCACK_MAPMOVE:
            let mapName = packet.mapName
            let position = SIMD2<Int>(Int(packet.xPos), Int(packet.yPos))
            playerPosition = position
            messages.append(.serverText("Map changed: \(mapName), position: \(position)"))

            // Notify map loaded
            var notifyPacket = PACKET_CZ_NOTIFY_ACTORINIT()
            notifyPacket.packetType = HEADER_CZ_NOTIFY_ACTORINIT
            mapClient?.sendPacket(notifyPacket)
        case let packet as PACKET_ZC_NOTIFY_PLAYERMOVE:
            let moveData = MoveData(from: packet.moveData)
            playerPosition = moveData.endPosition
            messages.append(.serverText("Player moved from \(moveData.startPosition) to \(moveData.endPosition)"))
        case let packet as PACKET_ZC_NOTIFY_CHAT:
            let message = ChatMessage(from: packet)
            messages.append(.serverText(message.content))
        case _ as PACKET_ZC_PING_LIVE:
            var packet = PACKET_CZ_PING_LIVE()
            packet.packetType = HEADER_CZ_PING_LIVE
            mapClient?.sendPacket(packet)
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            messages.append(.serverText("Banned"))

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                messages.append(.serverText(text))
            }
        default:
            break
        }
    }
}

extension ChatSession {
    static let previewing = ChatSession(serverAddress: "127.0.0.1", serverPort: "6900")
}
