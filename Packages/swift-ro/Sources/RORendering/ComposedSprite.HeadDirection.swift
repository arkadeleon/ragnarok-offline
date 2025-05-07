//
//  ComposedSprite.HeadDirection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/7.
//

extension ComposedSprite {
    public enum HeadDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
        case straight
        case left
        case right

        public var description: String {
            switch self {
            case .straight:
                "Straight"
            case .left:
                "Left"
            case .right:
                "Right"
            }
        }
    }
}
