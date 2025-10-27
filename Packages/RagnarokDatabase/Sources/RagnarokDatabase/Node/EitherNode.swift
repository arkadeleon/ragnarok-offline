//
//  EitherNode.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/1/12.
//

public enum EitherNode<Left, Right> {
    case left(Left)
    case right(Right)

    public func map<L, R>(left: (Left) -> L, right: (Right) -> R) -> EitherNode<L, R> {
        switch self {
        case .left(let l):
            .left(left(l))
        case .right(let r):
            .right(right(r))
        }
    }

    public func mapLeft<L>(_ transform: (Left) -> L) -> EitherNode<L, Right> {
        switch self {
        case .left(let l):
            .left(transform(l))
        case .right(let r):
            .right(r)
        }
    }

    public func mapRight<R>(_ transform: (Right) -> R) -> EitherNode<Left, R> {
        switch self {
        case .left(let l):
            .left(l)
        case .right(let r):
            .right(transform(r))
        }
    }
}

extension EitherNode: Decodable where Left: Decodable, Right: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let left = try? container.decode(Left.self) {
            self = .left(left)
        } else if let right = try? container.decode(Right.self) {
            self = .right(right)
        } else {
            throw DecodingError.typeMismatch(EitherNode<Left, Right>.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid type.", underlyingError: nil))
        }
    }
}

extension EitherNode: Equatable where Left: Equatable, Right: Equatable {
}

extension EitherNode: Hashable where Left: Hashable, Right: Hashable {
}

extension EitherNode: Sendable where Left: Sendable, Right: Sendable {
}
