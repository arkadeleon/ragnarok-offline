//
//  CharacterHeadDirection.swift
//  SpriteRendering
//
//  Created by Leon Li on 2025/5/7.
//

import Constants

public enum CharacterHeadDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
    case lookForward
    case lookRight
    case lookLeft

    public init(headDirection: HeadDirection) {
        switch headDirection {
        case .lookForward:
            self = .lookForward
        case .lookRight:
            self = .lookRight
        case .lookLeft:
            self = .lookLeft
        }
    }

    public var description: String {
        switch self {
        case .lookForward:
            "Look Forward"
        case .lookRight:
            "Look Right"
        case .lookLeft:
            "Look Left"
        }
    }
}
