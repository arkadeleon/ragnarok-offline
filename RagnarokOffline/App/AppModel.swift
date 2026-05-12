//
//  AppModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/3.
//

import Observation
import RagnarokGame
import RagnarokResources
import rAthenaChar
import rAthenaLogin
import rAthenaMap
import rAthenaResources
import rAthenaWeb

let localClientURL = URL.documentsDirectory
let remoteClientURL = URL(string: "http://ragnarokoffline.online/client")
let remoteClientCacheURL = URL.cachesDirectory.appending(path: "com.github.arkadeleon.ragnarok-offline-remote-client")
let serverWorkingDirectoryURL = URL.libraryDirectory.appending(path: "rathena", directoryHint: .isDirectory)

@MainActor
@Observable
final class AppModel {
    let mainWindowID = "Main"

    let settings = SettingsModel()

    let clientLocalDirectory = File(node: .directory(localClientURL), location: .client)
    let clientCachedDirectory = File(node: .directory(remoteClientCacheURL), location: .client)

    let serverDirectory = File(node: .directory(serverWorkingDirectoryURL), location: .server)

    let serverResourceManager = ServerResourceManager()
    let loginServer = ServerModel(server: LoginServer.shared)
    let charServer = ServerModel(server: CharServer.shared)
    let mapServer = ServerModel(server: MapServer.shared)
    let webServer = ServerModel(server: WebServer.shared)

    let database = DatabaseModel(mode: .renewal)

    let characterSimulator = CharacterSimulator()
    let skillSimulator = SkillSimulator()

    let chatSession: ChatSession
    let gameSession = GameSession(resourceManager: .shared)

    @ObservationIgnored
    private let serverConfiguration = ServerConfiguration(
        char_conf: """
            login_ip: 127.0.0.1
            stdout_with_ansisequence: yes
            char_name_option: 0
            char_del_delay: 0
            pincode_enabled: no
            """,
        login_conf: """
            stdout_with_ansisequence: yes
            new_account: yes
            """,
        map_conf: """
            char_ip: 127.0.0.1
            stdout_with_ansisequence: yes
            """,
        web_conf: """
            stdout_with_ansisequence: yes
            """
    )

    @ObservationIgnored
    private var serversToResume: [ServerModel] = []

    init() {
        chatSession = ChatSession(
            serverAddress: settings.serverAddress,
            serverPort: settings.serverPort
        )
    }

    func startServer(_ server: ServerModel) async throws {
        try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL, configuration: serverConfiguration)
        _ = await server.start()
    }

    func startAllServers() async throws {
        try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL, configuration: serverConfiguration)
        await startServers(allServers)
    }

    func stopServer(_ server: ServerModel) async {
        _ = await server.stop()
    }

    func stopAllServers() async {
        serversToResume.removeAll()
        await stopServers(allServers)
    }

    func pauseServers() async {
        serversToResume = runningServers()
        await stopServers(serversToResume)
    }

    func resumeServers() async throws {
        let servers = serversToResume
        serversToResume.removeAll()

        try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL, configuration: serverConfiguration)
        await startServers(servers)
    }

    private func startServers(_ servers: [ServerModel]) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            for server in servers {
                taskGroup.addTask {
                    _ = await server.start()
                }
            }
        }
    }

    private func stopServers(_ servers: [ServerModel]) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            for server in servers {
                taskGroup.addTask {
                    _ = await server.stop()
                }
            }
        }
    }

    private func runningServers() -> [ServerModel] {
        allServers.filter({ $0.status == .running })
    }

    private var allServers: [ServerModel] {
        [loginServer, charServer, mapServer, webServer]
    }
}

extension ResourceManager {
    static let shared = ResourceManager(
        localURL: localClientURL,
        remoteURL: remoteClientURL,
        remoteCacheURL: remoteClientCacheURL
    )
}
