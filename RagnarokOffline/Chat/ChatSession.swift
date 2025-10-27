//
//  ChatSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/15.
//

import RagnarokNetwork
import RagnarokPackets
import Observation
import RagnarokResources

@MainActor
@Observable
final class ChatSession {
    let serverAddress: String
    let serverPort: String

    enum Phase {
        case login
        case selectCharServer
        case selectChar
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
        case .selectChar:
            [.makeChar, .deleteChar, .selectChar]
        case .map:
            [.moveUp, .moveDown, .moveLeft, .moveRight]
        }
    }

    @ObservationIgnored
    private var account: AccountInfo?

    @ObservationIgnored
    private var charServers: [CharServerInfo] = []

    @ObservationIgnored
    private var chars: [CharInfo] = []

    @ObservationIgnored
    private var loginSession: LoginSession?
    @ObservationIgnored
    private var charSession: CharSession?
    @ObservationIgnored
    private var mapSession: MapSession?

    init(serverAddress: String, serverPort: String) {
        self.serverAddress = serverAddress
        self.serverPort = serverPort
    }

    func sendMessage(_ content: String) {
        messages.append(.clientText(content))

        if let mapSession {
            mapSession.sendMessage(content)
        }
    }

    func sendCommand(_ command: CommandMessage.Command, parameters: [String] = []) {
        messages.append(.command(command, parameters: parameters))

        switch command {
        case .login:
            startLoginSession()

            let username = parameters[0]
            let password = parameters[1]
            loginSession?.login(username: username, password: password)
        case .selectCharServer:
            guard let serverNumber = Int(parameters[0]),
                  serverNumber - 1 < charServers.count else {
                return
            }

            let charServer = charServers[serverNumber - 1]
            startCharSession(charServer)
        case .makeChar:
            var char = CharInfo()
            char.name = parameters[0]
            char.str = UInt8(parameters[1]) ?? 1
            char.agi = UInt8(parameters[2]) ?? 1
            char.vit = UInt8(parameters[3]) ?? 1
            char.int = UInt8(parameters[4]) ?? 1
            char.dex = UInt8(parameters[5]) ?? 1
            char.luk = UInt8(parameters[6]) ?? 1
            char.charNum = UInt8(parameters[7]) ?? 0

            charSession?.makeChar(char: char)
        case .deleteChar:
            break
        case .selectChar:
            let slot = UInt8(parameters[0]) ?? 0

            charSession?.selectChar(slot: slot)
        case .moveUp:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x, position.y + 1])
            }
        case .moveDown:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x, position.y - 1])
            }
        case .moveLeft:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x - 1, position.y])
            }
        case .moveRight:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x + 1, position.y])
            }
        }
    }

    // MARK: - Login Session

    private func startLoginSession() {
        guard let serverPort = UInt16(serverPort) else {
            return
        }

        let loginSession = LoginSession(address: serverAddress, port: serverPort)

        Task {
            for await event in loginSession.events {
                handleLoginEvent(event)
            }
        }

        loginSession.start()

        self.loginSession = loginSession
    }

    private func handleLoginEvent(_ event: LoginSession.Event) {
        switch event {
        case .loginAccepted(let account, let charServers):
            self.account = account
            self.charServers = charServers

            phase = .selectCharServer

            messages.append(.serverText("Accepted"))

            let charServers = charServers.enumerated()
                .map {
                    "(\($0.offset + 1)) \($0.element.name)"
                }
                .joined(separator: "\n")
            messages.append(.serverText(charServers))
        case .loginRefused(let message):
            messages.append(.serverText("Refused"))

            Task {
                let messageStringTable = await ResourceManager.shared.messageStringTable(for: .current)
                if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                    let text = text.replacingOccurrences(of: "%s", with: message.unblockTime)
                    messages.append(.serverText(text))
                }
            }
        case .authenticationBanned(let message):
            messages.append(.serverText("Banned"))

            Task {
                let messageStringTable = await ResourceManager.shared.messageStringTable(for: .current)
                if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                    messages.append(.serverText(text))
                }
            }
        case .errorOccurred(let error):
            messages.append(.serverText(error.localizedDescription))
        }
    }

    // MARK: - Char Session

    private func startCharSession(_ charServer: CharServerInfo) {
        guard let account else {
            return
        }

        let charSession = CharSession(account: account, charServer: charServer)

        Task {
            for await event in charSession.events {
                handleCharEvent(event)
            }
        }

        charSession.start()

        self.charSession = charSession
    }

    private func handleCharEvent(_ event: CharSession.Event) {
        switch event {
        case .charServerAccepted(let chars):
            self.chars = chars
            phase = .selectChar

            messages.append(.serverText("Accepted"))

            for char in chars {
                let message = """
                Char ID: \(char.charID)
                Name: \(char.name)
                Str: \(char.str)
                Agi: \(char.agi)
                Vit: \(char.vit)
                Int: \(char.int)
                Dex: \(char.dex)
                Luk: \(char.luk)
                Slot: \(char.charNum)
                """
                messages.append(.serverText(message))
            }
        case .charServerRefused:
            messages.append(.serverText("Refused"))
        case .charServerNotifiedMapServer(let charID, let mapName, let mapServer):
            phase = .map

            messages.append(.serverText("Entered map: \(mapName)"))

            startMapSession(charID: charID, mapName: mapName, mapServer: mapServer)
        case .charServerNotifiedAccessibleMaps(let accessibleMaps):
            break
        case .makeCharAccepted(let char):
            messages.append(.serverText("Accepted"))
        case .makeCharRefused:
            messages.append(.serverText("Refused"))
        case .deleteCharAccepted:
            break
        case .deleteCharRefused:
            break
        case .deleteCharCancelled:
            break
        case .deleteCharReserved(let deletionDate):
            break
        case .authenticationBanned(let message):
            messages.append(.serverText("Banned"))

            Task {
                let messageStringTable = await ResourceManager.shared.messageStringTable(for: .current)
                if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                    messages.append(.serverText(text))
                }
            }
        case .errorOccurred(let error):
            messages.append(.serverText(error.localizedDescription))
        }
    }

    // MARK: - Map Session

    private func startMapSession(charID: UInt32, mapName: String, mapServer: MapServerInfo) {
        guard let account = charSession?.account,
              let char = chars.first(where: { $0.charID == charID }) else {
            return
        }

        let mapSession = MapSession(account: account, char: char, mapServer: mapServer)

        Task {
            for await event in mapSession.events {
                handleMapEvent(event)
            }
        }

        mapSession.start()

        self.mapSession = mapSession
    }

    private func handleMapEvent(_ event: MapSession.Event) {
        switch event {
        case .mapChanged(let mapName, let position):
            playerPosition = position
            messages.append(.serverText("Map changed: \(mapName), position: \(position)"))

            // Load map.

            mapSession?.notifyMapLoaded()
        case .playerMoved(let startPosition, let endPosition):
            playerPosition = endPosition
            messages.append(.serverText("Player moved from \(startPosition) to \(endPosition)"))
        case .chatMessageReceived(let message):
            messages.append(.serverText("\(message.content)"))
        case .authenticationBanned(let message):
            messages.append(.serverText("Banned"))

            Task {
                let messageStringTable = await ResourceManager.shared.messageStringTable(for: .current)
                if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                    messages.append(.serverText(text))
                }
            }
        case .errorOccurred(let error):
            messages.append(.serverText(error.localizedDescription))
        default:
            break
        }
    }
}

extension ChatSession {
    static let previewing = ChatSession(serverAddress: "127.0.0.1", serverPort: "6900")
}
