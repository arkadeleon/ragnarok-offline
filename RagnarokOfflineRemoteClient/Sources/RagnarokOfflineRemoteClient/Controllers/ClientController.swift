//
//  ClientController.swift
//  RagnarokOfflineRemoteClient
//
//  Created by Leon Li on 2025/5/29.
//

import GRF
import Vapor

struct ClientController: RouteCollection {
    let resourcesDirectory: URL

    private let grfArchives: [GRFArchive]

    init(resourcesDirectory: String) {
        self.resourcesDirectory = URL(fileURLWithPath: resourcesDirectory)

        let grfURL = URL(fileURLWithPath: resourcesDirectory).appending(component: "data.grf")
        self.grfArchives = [
            GRFArchive(url: grfURL),
        ]
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("client", "**", use: client)
    }

    private func client(req: Request) async throws -> Response {
        guard req.url.path.hasPrefix("/client/") else {
            throw Abort(.badRequest)
        }

        guard let path = req.url.path.dropFirst("/client/".count).removingPercentEncoding else {
            throw Abort(.badRequest)
        }

        let fileURL = resourcesDirectory.appending(path: path)
        let filePath = fileURL.path(percentEncoded: false)
        if FileManager.default.fileExists(atPath: filePath) {
            return try await req.fileio.asyncStreamFile(at: filePath)
        }

        let components = path.split(separator: "/").map(String.init)
        let grfPath = GRFPath(components: components)
        for grfArchive in grfArchives {
            if let _ = await grfArchive.entry(at: grfPath) {
                let data = try await grfArchive.contentsOfEntry(at: grfPath)
                return Response(body: .init(data: data))
            }
        }

        throw Abort(.notFound)
    }
}
