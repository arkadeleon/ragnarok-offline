//
//  EitherNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/12.
//

public enum EitherNode<Left, Right>: Decodable where Left: Decodable, Right: Decodable {
    case left(Left)
    case right(Right)

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

    public func map<T>(left: (Left) -> T, right: (Right) -> T) -> T {
        switch self {
        case .left(let l):
            left(l)
        case .right(let r):
            right(r)
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

extension EitherNode: Equatable where Left: Equatable, Right: Equatable {
}

extension EitherNode: Hashable where Left: Hashable, Right: Hashable {
}

extension EitherNode: Sendable where Left: Sendable, Right: Sendable {
}
