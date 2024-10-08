//
//  ASTDumper.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/8.
//

import Foundation
import PackagePlugin

class ASTDumper {
    func dump(context: PluginContext, path: String) throws -> ASTNode {
        let srcURL = context.package.directoryURL.appending(path: "../swift-rathena/src")
        let inputURL = srcURL.appending(path: path)

        let process = Process()
        process.executableURL = try context.tool(named: "clang").url
        process.arguments = ["-Xclang", "-ast-dump=json", "-I" + srcURL.path(), inputURL.path()]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
//        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd()!

        let decoder = JSONDecoder()
        let ast = try decoder.decode(ASTNode.self, from: data)
        return ast
    }
}
