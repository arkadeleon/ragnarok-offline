//
//  GRFController.swift
//  RagnarokOfflineRemoteClient
//
//  Created by Leon Li on 2025/5/29.
//

import GRF
import Vapor

struct GRFQuery: Decodable {
    let path: GRFPath
}

struct GRFController: RouteCollection {
    let grf: GRFReference

    init(resourcesDirectory: String) {
        let url = URL(fileURLWithPath: resourcesDirectory).appending(component: "data.grf")
        self.grf = GRFReference(url: url)
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("grf", "directory", use: directory)
        routes.get("grf", "entry", use: entry)
    }

    func directory(req: Request) async throws -> String {
        let query = try req.query.decode(GRFQuery.self)
        let directory = grf.directory(at: query.path)
        let json = try JSONEncoder().encode(directory)
        return String(data: json, encoding: .utf8) ?? ""
    }

    func entry(req: Request) async throws -> Response {
        let query = try req.query.decode(GRFQuery.self)
        let data = try grf.contentsOfEntry(at: query.path)
        return Response(body: .init(data: data))
    }
}
