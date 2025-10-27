//
//  ClientSubscription.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2025/3/26.
//

import RagnarokPackets

typealias ClientErrorHandler = @Sendable (_ error: ClientError) -> Void

struct ClientSubscription {
    var errorHandlers: [ClientErrorHandler] = []
    var packetHandlers: [any PacketHandlerProtocol] = []

    mutating func subscribe(to type: ClientError.Type, _ handler: @escaping ClientErrorHandler) {
        errorHandlers.append(handler)
    }

    mutating func subscribe<P>(to type: P.Type, _ handler: @escaping @Sendable (P) -> Void) where P: RegisteredPacket {
        let packetHandler = PacketHandler(type: type, handler: handler)
        packetHandlers.append(packetHandler)
    }
}
