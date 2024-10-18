//
//  CodeGenerator.swift
//  ROTools
//
//  Created by Leon Li on 2024/10/18.
//

import ArgumentParser

@main
struct CodeGenerator: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "code-generator",
        abstract: "Generate Swift code from rAthena",
        subcommands: [
            GenerateConstantsCommand.self,
            GeneratePacketsCommand.self,
        ]
    )
}
