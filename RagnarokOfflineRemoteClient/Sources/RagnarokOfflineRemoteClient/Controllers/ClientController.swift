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

    private let languages: [String]
    private let grfArchivesByLanguage: [String : [GRFArchive]]

    init(resourcesDirectory: String) {
        let resourcesDirectory = URL(fileURLWithPath: resourcesDirectory)

        self.resourcesDirectory = resourcesDirectory

        self.languages = [
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

        self.grfArchivesByLanguage = [
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

        let language: String
        if let acceptLanguage = req.headers.first(name: .acceptLanguage) {
            language = languages.first(where: { $0.starts(with: acceptLanguage) || acceptLanguage.starts(with: $0) }) ?? "ko"
        } else {
            language = "ko"
        }

        let fileURL = resourcesDirectory.appending(path: language).appending(path: path)
        let filePath = fileURL.path(percentEncoded: false)
        if FileManager.default.fileExists(atPath: filePath) {
            return try await req.fileio.asyncStreamFile(at: filePath)
        }

        if let grfArchives = grfArchivesByLanguage[language] {
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
