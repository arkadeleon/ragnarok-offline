//
//  MapEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/26.
//

public enum MapEvents {
    public struct Changed: Event {
        public let mapName: String
        public let position: SIMD2<Int>
    }
}
