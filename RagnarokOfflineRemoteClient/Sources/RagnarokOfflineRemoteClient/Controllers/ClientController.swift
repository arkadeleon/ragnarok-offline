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
    let grfs: [GRFReference]

    init(resourcesDirectory: String) {
        self.resourcesDirectory = URL(fileURLWithPath: resourcesDirectory)

        let grfURL = URL(fileURLWithPath: resourcesDirectory).appending(component: "data.grf")
        self.grfs = [
            GRFReference(url: grfURL),
        ]
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("client", "**", use: client)
    }

    func client(req: Request) async throws -> Response {
        guard req.url.path.hasPrefix("/client/") else {
            return Response(status: .badRequest)
        }

        guard let path = req.url.path.dropFirst("/client/".count).removingPercentEncoding else {
            return Response(status: .badRequest)
        }

        let fileURL = resourcesDirectory.appending(path: path)
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return Response(body: .init(data: data))
        }

        let components = path.split(separator: "/").map(String.init)
        let grfPath = GRFPath(components: components)
        for grf in grfs {
            if let _ = grf.entry(at: grfPath) {
                let data = try grf.contentsOfEntry(at: grfPath)
                return Response(body: .init(data: data))
            }
        }

        return Response(status: .notFound)
    }
}
