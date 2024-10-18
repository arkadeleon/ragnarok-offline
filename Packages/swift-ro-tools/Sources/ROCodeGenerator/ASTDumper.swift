//
//  ASTDumper.swift
//  ROTools
//
//  Created by Leon Li on 2024/10/8.
//

import Foundation

class ASTDumper {
    let rathenaDirectory: URL

    init(rathenaDirectory: URL) {
        self.rathenaDirectory = rathenaDirectory
    }

    func dump(path: String) throws -> ASTNode {
        let srcURL = rathenaDirectory.appending(path: "src")
        let inputURL = srcURL.appending(path: path)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/clang")
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
