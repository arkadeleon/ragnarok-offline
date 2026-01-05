//
//  EitherNode.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/1/12.
//

public enum EitherNode<Left, Right> {
    case left(Left)
    case right(Right)

    public func map<L>(left transform: (Left) -> L) -> EitherNode<L, Right> {
        switch self {
        case .left(let value):
            .left(transform(value))
        case .right(let value):
            .right(value)
        }
    }

    public func map<R>(right transform: (Right) -> R) -> EitherNode<Left, R> {
        switch self {
        case .left(let value):
            .left(value)
        case .right(let value):
            .right(transform(value))
        }
    }

    public func map<L, R>(left leftTransform: (Left) -> L, right rightTransform: (Right) -> R) -> EitherNode<L, R> {
        switch self {
        case .left(let value):
            .left(leftTransform(value))
        case .right(let value):
            .right(rightTransform(value))
        }
    }
}

extension EitherNode: Decodable where Left: Decodable, Right: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Left.self) {
            self = .left(value)
        } else if let value = try? container.decode(Right.self) {
            self = .right(value)
        } else {
            throw DecodingError.typeMismatch(
                EitherNode<Left, Right>.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid type.", underlyingError: nil)
            )
        }
    }
}

extension EitherNode: Equatable where Left: Equatable, Right: Equatable {
}

extension EitherNode: Hashable where Left: Hashable, Right: Hashable {
}

extension EitherNode: Sendable where Left: Sendable, Right: Sendable {
}
