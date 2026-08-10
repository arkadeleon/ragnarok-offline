//
//  LoginEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/24.
//

import RagnarokModels

@available(*, deprecated, message: "Use raw packet instead.")
public enum LoginEvents {
    public struct Accepted: Event {
        public let account: AccountInfo
        public let charServers: [CharServerInfo]
    }

    public struct Refused: Event {
        public let message: LoginRefusedMessage
    }
}
