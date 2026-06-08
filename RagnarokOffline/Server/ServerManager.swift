//
//  ServerManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/22.
//

import Foundation
import Observation
import rAthenaChar
import rAthenaLogin
import rAthenaMap
import rAthenaResources
import rAthenaWeb

let serverWorkingDirectoryURL = URL.libraryDirectory.appending(path: "rathena", directoryHint: .isDirectory)

let serverConfiguration = ServerConfiguration(
    char_conf: """
        login_ip: 127.0.0.1
        stdout_with_ansisequence: yes
        char_name_option: 0
        char_del_delay: 0
        pincode_enabled: no
        """,
    groups: """
        Header:
          Type: PLAYER_GROUP_DB
          Version: 1

        Body:
          - Id: 0
            Commands:
              alive: true
              autoloot: true
              jobchange: true
              baselevelup: true
              heal: true
              joblevelup: true
              mapmove: true
              monster: true
              mount_peco: true
              agi: true
              dex: true
              int: true
              luk: true
              str: true
              vit: true
              zeny: true
            Permissions:
              any_warp: true
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

@MainActor
@Observable
final class ServerManager {
    let loginServer = ServerModel(server: LoginServer.shared)
    let charServer = ServerModel(server: CharServer.shared)
    let mapServer = ServerModel(server: MapServer.shared)
    let webServer = ServerModel(server: WebServer.shared)

    private let allServers: [ServerModel]
    private let serverResourceManager = ServerResourceManager()

    @ObservationIgnored private var serversToResume: [ServerModel] = []

    var allServersAreRunning: Bool {
        allServers.allSatisfy({ $0.status == .running })
    }

    init() {
        allServers = [loginServer, charServer, mapServer, webServer]
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
        serversToResume = allServers.filter({ $0.status == .running })
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
}
