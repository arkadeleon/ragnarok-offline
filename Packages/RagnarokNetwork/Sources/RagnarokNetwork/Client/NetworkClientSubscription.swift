//
//  NetworkClientSubscription.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2025/3/26.
//

import RagnarokPackets

typealias NetworkClientErrorHandler = @Sendable (_ error: NetworkClientError) -> Void

struct NetworkClientSubscription {
    var errorHandlers: [NetworkClientErrorHandler] = []
    var packetHandlers: [any PacketHandlerProtocol] = []

    mutating func subscribe(to type: NetworkClientError.Type, _ handler: @escaping NetworkClientErrorHandler) {
        errorHandlers.append(handler)
    }

    mutating func subscribe<P>(to type: P.Type, _ handler: @escaping @Sendable (P) -> Void) where P: DecodablePacket {
        let packetHandler = PacketHandler(type: type, handler: handler)
        packetHandlers.append(packetHandler)
    }
}
