//
//  ClientSubscription.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/26.
//

public typealias ClientErrorHandler = @Sendable (_ error: ClientError) -> Void

public struct ClientSubscription {
    var errorHandlers: [ClientErrorHandler] = []
    var packetHandlers: [any PacketHandlerProtocol] = []

    public init() {
    }

    public mutating func subscribe(to type: ClientError.Type, _ handler: @escaping ClientErrorHandler) {
        errorHandlers.append(handler)
    }

    public mutating func subscribe<P>(to type: P.Type, _ handler: @escaping @Sendable (P) -> Void) where P: RegisteredPacket {
        let packetHandler = PacketHandler(type: type, handler: handler)
        packetHandlers.append(packetHandler)
    }
}
