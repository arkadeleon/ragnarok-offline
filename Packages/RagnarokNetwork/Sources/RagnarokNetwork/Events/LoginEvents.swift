//
//  LoginEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/24.
//

import RagnarokModels

public enum LoginEvents {
    public struct Accepted: Event {
        public let account: AccountInfo
        public let charServers: [CharServerInfo]
    }

    public struct Refused: Event {
        public let message: LoginRefusedMessage
    }
}
