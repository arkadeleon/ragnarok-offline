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
    let clientDirectory = File(node: .directory(ResourceManager.shared.localURL))
    let serverDirectory = File(node: .directory(ServerResourceManager.default.workingDirectoryURL))

    let loginServer = ServerWrapper(server: LoginServer.shared)
    let charServer = ServerWrapper(server: CharServer.shared)
    let mapServer = ServerWrapper(server: MapServer.shared)
    let webServer = ServerWrapper(server: WebServer.shared)

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
