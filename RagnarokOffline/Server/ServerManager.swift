//
//  ServerManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/22.
//

import Foundation
import Observation
import rAthenaChar
import rAthenaCharPre
import rAthenaCommon
import rAthenaLogin
import rAthenaLoginPre
import rAthenaMap
import rAthenaMapPre
import rAthenaResources
import rAthenaWeb
import rAthenaWebPre

let serverWorkingDirectoryURL = URL.libraryDirectory.appending(path: "rathena", directoryHint: .isDirectory)

let serverConfiguration = ServerConfiguration(
    battle_conf: """
        area_size: 26
        max_walk_path: 32
        """,
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
              mapmove: true
              jobchange: true
              alive: true
              heal: true
              item: true
              baselevelup: true
              joblevelup: true
              monster: true
              zeny: true
              str: true
              agi: true
              vit: true
              int: true
              dex: true
              luk: true
              mount_peco: true
              autoloot: true
              effect: true
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
    private(set) var mode: ServerMode

    var loginServer: ServerModel {
        switch mode {
        case .prerenewal: prerenewalLoginServer
        case .renewal: renewalLoginServer
        }
    }

    var charServer: ServerModel {
        switch mode {
        case .prerenewal: prerenewalCharServer
        case .renewal: renewalCharServer
        }
    }

    var mapServer: ServerModel {
        switch mode {
        case .prerenewal: prerenewalMapServer
        case .renewal: renewalMapServer
        }
    }

    var webServer: ServerModel {
        switch mode {
        case .prerenewal: prerenewalWebServer
        case .renewal: renewalWebServer
        }
    }

    private let renewalLoginServer = ServerModel(server: LoginServer.shared)
    private let renewalCharServer = ServerModel(server: CharServer.shared)
    private let renewalMapServer = ServerModel(server: MapServer.shared)
    private let renewalWebServer = ServerModel(server: WebServer.shared)

    private let prerenewalLoginServer = ServerModel(server: LoginServerPre.shared)
    private let prerenewalCharServer = ServerModel(server: CharServerPre.shared)
    private let prerenewalMapServer = ServerModel(server: MapServerPre.shared)
    private let prerenewalWebServer = ServerModel(server: WebServerPre.shared)

    private var allServers: [ServerModel] {
        [loginServer, charServer, mapServer, webServer]
    }

    private let serverResourceManager = ServerResourceManager()

    @ObservationIgnored private var serversToResume: [ServerModel] = []

    var allServersAreRunning: Bool {
        allServers.allSatisfy({ $0.status == .running })
    }

    init(mode: ServerMode) {
        self.mode = mode
    }

    func setMode(_ mode: ServerMode) async {
        guard mode != self.mode else {
            return
        }

        await stopAllServers()

        self.mode = mode
    }

    func startServer(_ server: ServerModel) async throws {
        try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL, mode: mode, configuration: serverConfiguration)
        _ = await server.start()
    }

    func startAllServers() async throws {
        try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL, mode: mode, configuration: serverConfiguration)
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

        try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL, mode: mode, configuration: serverConfiguration)
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
