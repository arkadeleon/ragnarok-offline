//
//  ConnectionEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/25.
//

@available(*, deprecated, message: "Use raw packet instead.")
public enum ConnectionEvents {
    public struct ErrorOccurred: Event {
        public let error: any Error
    }
}
