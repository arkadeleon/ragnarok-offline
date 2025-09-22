//
//  GRFPath.swift
//  GRF
//
//  Created by Leon Li on 2025/2/28.
//

@GRFActor
public class GRFPath {
    /// A string representation of the path.
    nonisolated public let string: String

    /// The parent path.
    lazy var parent: GRFPath = {
        let parent: GRFPath
        let startIndex = string.startIndex
        if let endIndex = string.lastIndex(of: "\\") {
            let substring = string[startIndex..<endIndex]
            parent = GRFPath(string: String(substring))
        } else {
            parent = GRFPath(string: "")
        }
        return parent
    }()

    /// The components.
    nonisolated public var components: [String] {
        string.split(separator: "\\").map(String.init)
    }

    /// The last path component (including any extension).
    nonisolated public var lastComponent: String {
        string.split(separator: "\\").last.map(String.init) ?? ""
    }

    /// The last path component (without any extension).
    nonisolated public var stem: String {
        lastComponent.split(separator: ".").dropLast().joined(separator: ".")
    }

    /// The filename extension (without any leading dot).
    nonisolated public var `extension`: String {
        lastComponent.split(separator: ".").last.map(String.init) ?? ""
    }

    nonisolated init(string: String) {
        self.string = string
    }

    nonisolated public init(components: [String]) {
        self.string = components.joined(separator: "\\")
    }

    /// The result of replacing with the new extension.
    nonisolated public func replacingExtension(_ newExtension: String) -> GRFPath {
        let newLastComponent = stem + "." + newExtension
        return replacingLastComponent(newLastComponent)
    }

    /// The result of replacing with the new last component.
    nonisolated public func replacingLastComponent(_ newLastComponent: String) -> GRFPath {
        var newComponents = components
        newComponents.removeLast()
        newComponents.append(newLastComponent)
        return GRFPath(components: newComponents)
    }
}

extension GRFPath: @GRFActor Equatable {
    public static func == (lhs: GRFPath, rhs: GRFPath) -> Bool {
        lhs.string == rhs.string
    }
}

extension GRFPath: @GRFActor Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
}
