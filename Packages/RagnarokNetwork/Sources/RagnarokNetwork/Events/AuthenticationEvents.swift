//
//  AuthenticationEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/25.
//

public enum AuthenticationEvents {
    public struct Banned: Event {
        public let message: BannedMessage
    }
}
