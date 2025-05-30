//
//  ClientController.swift
//  RagnarokOfflineRemoteClient
//
//  Created by Leon Li on 2025/5/29.
//

import GRF
import Vapor

struct ClientController: RouteCollection {
    let grf: GRFReference

    init(resourcesDirectory: String) {
        let url = URL(fileURLWithPath: resourcesDirectory).appending(component: "data.grf")
        self.grf = GRFReference(url: url)
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("client", "files", "**", use: files)
        routes.get("client", "file", "**", use: file)
    }

    func files(req: Request) async throws -> String {
        let components = req.url.path.dropFirst(13).split(separator: "/").map({ $0.removingPercentEncoding ?? "" })
        let path = GRFPath(components: components)
        let directory = grf.directory(at: path)
        let json = try JSONEncoder().encode(directory)
        return String(data: json, encoding: .utf8) ?? ""
    }

    func file(req: Request) async throws -> Response {
        let components = req.url.path.dropFirst(13).split(separator: "/").map({ $0.removingPercentEncoding ?? "" })
        let path = GRFPath(components: components)
        let data = try grf.contentsOfEntry(at: path)
        return Response(body: .init(data: data))
    }
}
