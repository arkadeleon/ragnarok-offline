//
//  ConnectionEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

public enum ConnectionEvents {
    public struct ErrorOccurred: Event {
        public let error: any Error
    }
}
