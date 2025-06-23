//
//  ResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import AVFAudio
import CoreGraphics
import Foundation
import GRF
import ROCore

enum ResourceError: LocalizedError {
    case resourceNotFound(ResourcePath)
    case cannotCreateImage

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let path):
            String(localized: "Resource not found at \(path.components.joined(separator: "/"))")
        case .cannotCreateImage:
            String(localized: "Cannot create image")
        }
    }
}

public enum ResourceLocator {
    case url(URL)
    case grfArchiveEntry(GRFArchive, GRFEntryNode)
}

final public class ResourceManager: Sendable {
    public let localURL: URL
    public let remoteURL: URL?

    private let localGRFArchives: [GRFArchive]

    public init(localURL: URL, remoteURL: URL?) {
        self.localURL = localURL
        self.remoteURL = remoteURL

        let dataGRFURL = localURL.appending(path: "data.grf")

        if !FileManager.default.fileExists(atPath: dataGRFURL.path()) {
            let data = Data()
            let url = localURL.appending(path: "Copy data.grf Here")
            do {
                try data.write(to: url)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        localGRFArchives = [
            GRFArchive(url: dataGRFURL),
        ]
    }

    public func locatorOfResource(at path: ResourcePath) async throws -> ResourceLocator {
        let fileURL = localURL.absoluteURL.appending(path: path)
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return .url(fileURL)
        }

        let components = path.components.map({ $0.transcoding(from: .koreanEUC, to: .isoLatin1) ?? $0 })
        let grfPath = GRFPath(components: components)
        for grfArchive in localGRFArchives {
            if let entry = await grfArchive.entry(at: grfPath) {
                return .grfArchiveEntry(grfArchive, entry)
            }
        }

        #if DEBUG
        if let fileURL = Bundle.main.resourceURL?.appending(path: path),
           FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return .url(fileURL)
        }
        #endif

        throw ResourceError.resourceNotFound(path)
    }

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let fileURL = localURL.absoluteURL.appending(path: path)
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }

        let components = path.components.map({ $0.transcoding(from: .koreanEUC, to: .isoLatin1) ?? $0 })
        let grfPath = GRFPath(components: components)
        for grfArchive in localGRFArchives {
            if let entry = await grfArchive.entry(at: grfPath) {
                let data = try await grfArchive.contentsOfEntry(at: entry.path)
                return data
            }
        }

        #if DEBUG
        if let fileURL = Bundle.main.resourceURL?.appending(path: path),
           FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }
        #endif

        if let remoteURL {
            logger.info("Start downloading resource: \(path)")

            let path = ResourcePath(components: path.components.map({ $0.transcoding(from: .koreanEUC, to: .isoLatin1) ?? $0 }))
            let remoteResourceURL = remoteURL.appending(path: path)
            let (data, _) = try await URLSession.shared.data(from: remoteResourceURL)
            return data
        }

        throw ResourceError.resourceNotFound(path)
    }
}

extension ResourceManager {
    public func image(at path: ResourcePath, removesMagentaPixels: Bool = false) async throws -> CGImage {
        let data = try await contentsOfResource(at: path)

        var image = CGImageCreateWithData(data)
        if removesMagentaPixels {
            image = image?.removingMagentaPixels()
        }

        if let image {
            return image
        } else {
            throw ResourceError.cannotCreateImage
        }
    }
}

extension ResourceManager {
    public func audio(at path: ResourcePath) async -> AVAudioBuffer? {
        guard let data = try? await contentsOfResource(at: path) else {
            return nil
        }

        // Create a temporary file
        let uuid = UUID().uuidString
        let tempURL = URL.temporaryDirectory.appending(path: uuid)

        do {
            try data.write(to: tempURL)
            let audioFile = try AVAudioFile(forReading: tempURL)

            let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            )

            if let buffer {
                try audioFile.read(into: buffer)
            }

            // Clean up
            try? FileManager.default.removeItem(at: tempURL)

            return buffer
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }
}
