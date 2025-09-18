//
//  GenerateCommand.swift
//  RagnarokOfflineGenerator
//
//  Created by Leon Li on 2024/10/18.
//

import ArgumentParser

@main
struct GenerateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ragnarok-offline-generator",
        abstract: "Generate Swift code for Ragnarok Offline from rAthena",
        subcommands: [
            GenerateConstantsCommand.self,
            GeneratePacketsCommand.self,
        ]
    )
}
