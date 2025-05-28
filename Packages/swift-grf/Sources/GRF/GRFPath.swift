//
//  GRFPath.swift
//  GRF
//
//  Created by Leon Li on 2025/2/28.
//

final public class GRFPath: Hashable {
    public static func == (lhs: GRFPath, rhs: GRFPath) -> Bool {
        lhs.string == rhs.string
    }

    /// A string representation of the path.
    public let string: String

    /// The parent path.
    public lazy var parent: GRFPath = {
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

    init(string: String) {
        self.string = string
    }

    public init(components: [String]) {
        self.string = components.joined(separator: "\\")
    }

    public func appending(_ components: [String]) -> GRFPath {
        GRFPath(string: ([string] + components).joined(separator: "\\"))
    }

    /// The result of replacing with the new extension.
    public func replacingExtension(_ newExtension: String) -> GRFPath {
        let newLastComponent = stem + "." + newExtension
        let newString = parent.string + "\\" + newLastComponent
        return GRFPath(string: newString)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
}
