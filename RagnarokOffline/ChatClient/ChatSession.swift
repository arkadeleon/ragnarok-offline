//
//  ChatSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/15.
//

import Observation
import RagnarokLocalization
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
    private var loginSession: LoginSession?
    @ObservationIgnored
    private var charSession: CharSession?
    @ObservationIgnored
    private var mapSession: MapSession?

    init(serverAddress: String, serverPort: String) {
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.messageStringTable = MessageStringTable()
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
        case .makeCharacter:
            var character = CharacterInfo()
            character.name = parameters[0]
            character.str = Int(parameters[1]) ?? 1
            character.agi = Int(parameters[2]) ?? 1
            character.vit = Int(parameters[3]) ?? 1
            character.int = Int(parameters[4]) ?? 1
            character.dex = Int(parameters[5]) ?? 1
            character.luk = Int(parameters[6]) ?? 1
            character.charNum = Int(parameters[7]) ?? 0

            charSession?.makeCharacter(character: character)
        case .deleteCharacter:
            break
        case .selectCharacter:
            let slot = Int(parameters[0]) ?? 0

            charSession?.selectCharacter(slot: slot)
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

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                let text = text.replacingOccurrences(of: "%s", with: message.unblockTime)
                messages.append(.serverText(text))
            }
        case .authenticationBanned(let message):
            messages.append(.serverText("Banned"))

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                messages.append(.serverText(text))
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
        case .charServerAccepted(let characters):
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
        case .charServerRefused:
            messages.append(.serverText("Refused"))
        case .charServerNotifiedMapServer(let charID, let mapName, let mapServer):
            phase = .map

            messages.append(.serverText("Entered map: \(mapName)"))

            startMapSession(charID: charID, mapName: mapName, mapServer: mapServer)
        case .charServerNotifiedAccessibleMaps(let accessibleMaps):
            break
        case .makeCharacterAccepted(let character):
            messages.append(.serverText("Accepted"))
        case .makeCharacterRefused:
            messages.append(.serverText("Refused"))
        case .deleteCharacterAccepted:
            break
        case .deleteCharacterRefused:
            break
        case .deleteCharacterCancelled:
            break
        case .deleteCharacterReserved(let deletionDate):
            break
        case .authenticationBanned(let message):
            messages.append(.serverText("Banned"))

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                messages.append(.serverText(text))
            }
        case .errorOccurred(let error):
            messages.append(.serverText(error.localizedDescription))
        }
    }

    // MARK: - Map Session

    private func startMapSession(charID: UInt32, mapName: String, mapServer: MapServerInfo) {
        guard let account = charSession?.account,
              let character = characters.first(where: { $0.charID == charID }) else {
            return
        }

        let mapSession = MapSession(account: account, character: character, mapServer: mapServer)

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

            if let text = messageStringTable.localizedMessageString(forID: message.messageID) {
                messages.append(.serverText(text))
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
