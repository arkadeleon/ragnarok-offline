//
//  ResourcePath.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/12.
//

import Foundation

public struct ResourcePath: ExpressibleByArrayLiteral, Sendable {
    public static func + (lhs: ResourcePath, rhs: ResourcePath) -> ResourcePath {
        ResourcePath(components: lhs.components + rhs.components)
    }

    public let components: [String]

    public init(components: [String]) {
        self.components = components
    }

    public init(arrayLiteral elements: String...) {
        self.components = elements
    }

    public func appending(component: String) -> ResourcePath {
        ResourcePath(components: components + [component])
    }

    public func appending(components: [String]) -> ResourcePath {
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
    public static let scriptPath: ResourcePath = ["data", "luafiles514", "lua files"]
    public static let modelPath: ResourcePath = ["data", "model"]
    public static let palettePath: ResourcePath = ["data", "palette"]
    public static let spritePath: ResourcePath = ["data", "sprite"]
    public static let texturePath: ResourcePath = ["data", "texture"]
    public static let effectPath: ResourcePath = ["data", "texture", "effect"]
    public static let userInterface: ResourcePath = ["data", "texture", "유저인터페이스"]
}

extension URL {
    public func appending(path: ResourcePath, directoryHint: URL.DirectoryHint = .inferFromPath) -> URL {
        let path = path.components.joined(separator: "/")
        let url = appending(path: path, directoryHint: directoryHint)
        return url
    }
}
