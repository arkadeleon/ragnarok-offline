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
    private let cache: NSCache<NSString, NSData>

    init(resourcesDirectory: String) {
        self.resourcesDirectory = URL(fileURLWithPath: resourcesDirectory)

        let grfURL = URL(fileURLWithPath: resourcesDirectory).appending(component: "data.grf")
        self.grfArchives = [
            GRFArchive(url: grfURL),
        ]

        self.cache = NSCache()
        self.cache.totalCostLimit = 512 * 1024 * 1024
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("client", "**", use: client)
    }

    private func client(req: Request) async throws -> Response {
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

        if let data = cache.object(forKey: path as NSString) {
            return Response(body: .init(data: data as Data))
        }

        let components = path.split(separator: "/").map(String.init)
        let grfPath = GRFPath(components: components)
        for grfArchive in grfArchives {
            if let _ = await grfArchive.entry(at: grfPath) {
                let data = try await grfArchive.contentsOfEntry(at: grfPath)
                cache.setObject(data as NSData, forKey: path as NSString, cost: data.count)
                return Response(body: .init(data: data))
            }
        }

        return Response(status: .notFound)
    }
}
