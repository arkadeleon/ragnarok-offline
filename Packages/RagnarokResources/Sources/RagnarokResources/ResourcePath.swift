//
//  ResourcePath.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/2/12.
//

import Foundation
import TextEncoding

public func L2K(_ path: ResourcePath) -> ResourcePath {
    let components = path.components.map(L2K)
    return ResourcePath(components: components)
}

public struct ResourcePath: ExpressibleByArrayLiteral, Sendable {
    public let components: [String]

    public init(components: [String]) {
        self.components = components
    }

    public init(arrayLiteral elements: String...) {
        self.components = elements
    }

    public func appending(_ path: ResourcePath) -> ResourcePath {
        ResourcePath(components: components + path.components)
    }

    public func appending(_ component: String) -> ResourcePath {
        ResourcePath(components: components + [component])
    }

    public func appending(_ components: [String]) -> ResourcePath {
        ResourcePath(components: self.components + components)
    }

    public func appendingPathExtension(_ pathExtension: String) -> ResourcePath {
        var components = components
        if var lastComponent = components.popLast() {
            lastComponent.append(".")
            lastComponent.append(pathExtension)
            components.append(lastComponent)
        }
        return ResourcePath(components: components)
    }
}

extension ResourcePath {
    public static func + (lhs: ResourcePath, rhs: ResourcePath) -> ResourcePath {
        ResourcePath(components: lhs.components + rhs.components)
    }
}

extension ResourcePath: CustomStringConvertible {
    public var description: String {
        components.joined(separator: "/")
    }
}

extension URL {
    public func appending(path: ResourcePath, directoryHint: URL.DirectoryHint = .inferFromPath) -> URL {
        let path = path.components.joined(separator: "/")
        let url = appending(path: path, directoryHint: directoryHint)
        return url
    }
}
