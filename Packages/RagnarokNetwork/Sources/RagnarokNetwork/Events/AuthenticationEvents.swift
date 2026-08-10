//
//  AuthenticationEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/25.
//

import RagnarokModels

@available(*, deprecated, message: "Use raw packet instead.")
public enum AuthenticationEvents {
    public struct Banned: Event {
        public let message: BannedMessage
    }
}
