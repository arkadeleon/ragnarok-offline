//
//  AppModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/3.
//

import Observation
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import rAthenaResources
import ROResources

@MainActor
@Observable
final class AppModel {
    let mainWindowID = "Main"
    let gameImmersiveSpaceID = "Game"

    let clientDirectory = File(node: .directory(localClientURL))
    let clientCachesDirectory = File(node: .directory(remoteClientCachesURL))

    let serverDirectory = File(node: .directory(ServerResourceManager.shared.workingDirectoryURL))
    let loginServer = ServerModel(server: LoginServer.shared)
    let charServer = ServerModel(server: CharServer.shared)
    let mapServer = ServerModel(server: MapServer.shared)
    let webServer = ServerModel(server: WebServer.shared)

    var itemDatabase = DatabaseModel(mode: .renewal, recordProvider: .item)
    var jobDatabase = DatabaseModel(mode: .renewal, recordProvider: .job)
    var mapDatabase = DatabaseModel(mode: .renewal, recordProvider: .map)
    var monsterDatabase = DatabaseModel(mode: .renewal, recordProvider: .monster)
    var monsterSummonDatabase = DatabaseModel(mode: .renewal, recordProvider: .monsterSummon)
    var petDatabase = DatabaseModel(mode: .renewal, recordProvider: .pet)
    var skillDatabase = DatabaseModel(mode: .renewal, recordProvider: .skill)
    var statusChangeDatabase = DatabaseModel(mode: .renewal, recordProvider: .statusChange)

    let characterSimulator = CharacterSimulator()
}
