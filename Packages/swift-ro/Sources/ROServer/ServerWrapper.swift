//
//  ServerWrapper.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/14.
//

@preconcurrency import Combine
@preconcurrency import rAthenaLogin
@preconcurrency import rAthenaChar
@preconcurrency import rAthenaMap
@preconcurrency import rAthenaWeb

final public class ServerWrapper: Sendable {
    public static let login = ServerWrapper(server: LoginServer.shared)
    public static let char = ServerWrapper(server: CharServer.shared)
    public static let map = ServerWrapper(server: MapServer.shared)
    public static let web = ServerWrapper(server: WebServer.shared)

    private let server: Server

    public var name: String {
        server.name
    }

    public var status: Status {
        Status(status: server.status)
    }

    public let statusPublisher: AnyPublisher<Status, Never>

    public let outputDataPublisher: AnyPublisher<Data, Never>

    init(server: Server) {
        self.server = server

        statusPublisher = server.publisher(for: \.status)
            .map(Status.init)
            .eraseToAnyPublisher()

        outputDataPublisher = NotificationCenter.default.publisher(for: .ServerDidOutputData, object: server)
            .map { $0.userInfo![ServerOutputDataKey] as! Data }
            .eraseToAnyPublisher()
    }

    public func start() async {
        await server.start()
    }

    public func stop() async {
        await server.stop()
    }
}

extension ServerWrapper {
    public enum Status: CustomLocalizedStringResourceConvertible {
        case notStarted
        case starting
        case running
        case stopping
        case stopped

        init(status: ServerStatus) {
            switch status {
            case .notStarted:
                self = .notStarted
            case .starting:
                self = .starting
            case .running:
                self = .running
            case .stopping:
                self = .stopping
            case .stopped:
                self = .stopped
            @unknown default:
                fatalError()
            }
        }

        public var localizedStringResource: LocalizedStringResource {
            switch self {
            case .notStarted: "NOT STARTED"
            case .starting: "STARTING"
            case .running: "RUNNING"
            case .stopping: "STOPPING"
            case .stopped: "STOPPED"
            }
        }
    }
}
