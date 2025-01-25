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

    private let statusSubject: CurrentValueSubject<ServerWrapper.Status, Never>
    private let statusSubscription: AnyCancellable
    public let statusPublisher: AnyPublisher<ServerWrapper.Status, Never>

    private let consoleMessagesSubject: CurrentValueSubject<[AttributedString], Never>
    private let consoleMessagesSubscription: AnyCancellable
    public let consoleMessagesPublisher: AnyPublisher<[AttributedString], Never>

    private let consoleActionSubject = PassthroughSubject<ServerWrapper.ConsoleAction, Never>()

    public var name: String {
        server.name
    }

    public var status: ServerWrapper.Status {
        statusSubject.value
    }

    public var consoleMessages: [AttributedString] {
        consoleMessagesSubject.value
    }

    init(server: Server) {
        self.server = server

        statusSubject = CurrentValueSubject(ServerWrapper.Status(status: server.status))
        statusSubscription = server.publisher(for: \.status)
            .map(ServerWrapper.Status.init)
            .subscribe(statusSubject)
        statusPublisher = statusSubject.eraseToAnyPublisher()

        let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.server-output", qos: .userInitiated)
        consoleMessagesSubject = CurrentValueSubject([])
        consoleMessagesSubscription = NotificationCenter.default.publisher(for: .ServerDidOutputData, object: server)
            .receive(on: queue)
            .map {
                let data = $0.userInfo![ServerOutputDataKey] as! Data
                let consoleAction = ServerWrapper.ConsoleAction(data: data)
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
            .subscribe(consoleMessagesSubject)
        consoleMessagesPublisher = consoleMessagesSubject.eraseToAnyPublisher()
    }

    public func start() async -> Bool {
        await server.start()
    }

    public func stop() async -> Bool {
        await server.stop()
    }

    public func clearConsole() {
        consoleActionSubject.send(.clear)
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

    private enum ConsoleAction {
        case append(Data)
        case clear

        init(data: Data) {
            self = .append(data)
        }
    }
}
