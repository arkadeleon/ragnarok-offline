//
//  GenerateConstantsCommand.swift
//  ROTools
//
//  Created by Leon Li on 2024/10/18.
//

import ArgumentParser
import Foundation

struct GenerateConstantsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "generate-constants")

    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var rathenaDirectory: URL

    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var generatedDirectory: URL

    mutating func run() throws {
        try? FileManager.default.removeItem(at: generatedDirectory)
        try? FileManager.default.createDirectory(at: generatedDirectory, withIntermediateDirectories: true)

        try generateConstants()
    }

    func generateConstants() throws {
        let converter = ConstantConverter(rathenaDirectory: rathenaDirectory)
        for conversion in allConstantConversions {
            let outputContents = try converter.convert(conversion: conversion)

            let outputURL = generatedDirectory.appending(path: "\(conversion.outputType).swift")
            try outputContents.write(to: outputURL, atomically: true, encoding: .utf8)
        }
    }
}
