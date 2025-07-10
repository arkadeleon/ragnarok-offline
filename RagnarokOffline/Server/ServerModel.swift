//
//  ServerModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/14.
//

@preconcurrency import Combine
@preconcurrency import rAthenaCommon

@MainActor
@Observable
final class ServerModel {
    private let server: Server

    var name: String {
        server.name
    }

    var status: ServerModel.Status

    var consoleMessages: [AttributedString]

    private let consoleActionSubject = PassthroughSubject<ServerModel.ConsoleAction, Never>()

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    init(server: Server) {
        self.server = server
        self.status = ServerModel.Status(status: server.status)
        self.consoleMessages = []

        server.publisher(for: \.status)
            .map(ServerModel.Status.init)
            .receive(on: RunLoop.main)
            .assign(to: \.status, on: self)
            .store(in: &subscriptions)

        let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.server-output", qos: .userInitiated)
        NotificationCenter.default.publisher(for: .ServerDidOutputData, object: server)
            .receive(on: queue)
            .map {
                let data = $0.userInfo![ServerOutputDataKey] as! Data
                let consoleAction = ServerModel.ConsoleAction(data: data)
                return consoleAction
            }
            .merge(with: consoleActionSubject)
            .scan([AttributedString]()) { result, action in
                switch action {
                case .append(let data):
                    var result = result
                    guard let output = String(data: data, encoding: .isoLatin1) else {
                        return result
                    }
                    if let last = result.last, last.characters.last == "\r" {
                        result.removeLast()
                    }
                    let lines = output.split(separator: "\n")
                    for line in lines where !line.isEmpty {
                        let attributedString = AttributedString(logMessage: String(line))
                        result.append(attributedString)
                    }
                    if result.count > 1000 {
                        result.removeFirst(result.count - 1000)
                    }
                    return result
                case .clear:
                    return []
                }
            }
            .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
            .assign(to: \.consoleMessages, on: self)
            .store(in: &subscriptions)
    }

    func start() async -> Bool {
        await server.start()
    }

    func stop() async -> Bool {
        await server.stop()
    }

    func clearConsole() {
        consoleActionSubject.send(.clear)
    }
}

extension ServerModel {
    enum Status: CustomLocalizedStringResourceConvertible {
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

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .notStarted: "NOT STARTED"
            case .starting: "STARTING"
            case .running: "RUNNING"
            case .stopping: "STOPPING"
            case .stopped: "STOPPED"
            }
        }
    }

    private enum ConsoleAction {
        case append(Data)
        case clear

        init(data: Data) {
            self = .append(data)
        }
    }
}
