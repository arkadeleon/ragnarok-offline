//
//  GRFPath.swift
//  GRF
//
//  Created by Leon Li on 2025/2/28.
//

public struct GRFPath: Sendable {

    /// A string representation of the path.
    public let string: String

    /// The components.
    public var components: [String] {
        string.split(separator: "\\").map(String.init)
    }

    /// The last path component (including any extension).
    public var lastComponent: String {
        string.split(separator: "\\").last.map(String.init) ?? ""
    }

    /// The last path component (without any extension).
    public var stem: String {
        lastComponent.split(separator: ".").dropLast().joined(separator: ".")
    }

    /// The filename extension (without any leading dot).
    public var `extension`: String {
        lastComponent.split(separator: ".").last.map(String.init) ?? ""
    }

    init(path: GRFPathReference) {
        self.string = path.string
    }

    public init(components: [String]) {
        self.string = components.joined(separator: "\\")
    }

    /// The result of replacing with the new extension.
    public func replacingExtension(_ newExtension: String) -> GRFPath {
        let newLastComponent = stem + "." + newExtension
        return replacingLastComponent(newLastComponent)
    }

    /// The result of replacing with the new last component.
    public func replacingLastComponent(_ newLastComponent: String) -> GRFPath {
        var newComponents = components
        newComponents.removeLast()
        newComponents.append(newLastComponent)
        return GRFPath(components: newComponents)
    }
}

class GRFPathReference: Equatable, Hashable {
    static func == (lhs: GRFPathReference, rhs: GRFPathReference) -> Bool {
        lhs.string == rhs.string
    }

    let string: String

    var `extension`: Substring {
        string.split(separator: "\\").last?.split(separator: ".").last ?? ""
    }

    lazy var parent: GRFPathReference = {
        let parent: GRFPathReference
        let startIndex = string.startIndex
        if let endIndex = string.lastIndex(of: "\\") {
            let substring = string[startIndex..<endIndex]
            parent = GRFPathReference(string: String(substring))
        } else {
            parent = GRFPathReference(string: "")
        }
        return parent
    }()

    init(string: String) {
        self.string = string
    }

    init(path: GRFPath) {
        self.string = path.string
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
}
