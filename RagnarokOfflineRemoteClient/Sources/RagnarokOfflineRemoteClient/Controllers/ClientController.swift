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

    private let locales: [String]
    private let grfArchivesByLocale: [String : [GRFArchive]]

    init(resourcesDirectory: String) {
        let resourcesDirectory = URL(fileURLWithPath: resourcesDirectory)

        self.resourcesDirectory = resourcesDirectory

        self.locales = [
            "de",
            "en",
            "es",
            "fr",
            "id",
            "it",
            "ja",
            "ko",
            "pt-BR",
            "ru",
            "th",
            "tr",
            "zh-Hans",
            "zh-Hant",
        ]

        self.grfArchivesByLocale = [
            "ko": [
                GRFArchive(url: resourcesDirectory.appending(components: "ko", "data.grf")),
            ],
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

        let components = path.split(separator: "/").map(String.init)
        guard components.count > 0 else {
            throw Abort(.badRequest)
        }

        var locale = "ko"
        if let l = req.headers.first(name: "RO-Locale"), locales.contains(l) {
            locale = l
        }

        let fileURL = resourcesDirectory.appending(path: locale).appending(path: path)
        let filePath = fileURL.path(percentEncoded: false)
        if FileManager.default.fileExists(atPath: filePath) {
            return try await req.fileio.asyncStreamFile(at: filePath)
        }

        if let grfArchives = grfArchivesByLocale[locale] {
            let grfPath = GRFPath(components: components)
            for grfArchive in grfArchives {
                if let _ = await grfArchive.entry(at: grfPath) {
                    let data = try await grfArchive.contentsOfEntry(at: grfPath)
                    return Response(body: .init(data: data))
                }
            }
        }

        throw Abort(.notFound)
    }
}
