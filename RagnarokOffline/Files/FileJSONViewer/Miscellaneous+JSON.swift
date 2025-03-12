//
//  Miscellaneous+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/16.
//

import ROCore
import ROFileFormats

extension RGBAColor {
    var json: String {
        "\(red), \(green), \(blue), \(alpha)".parenthesized.quoted
    }
}

extension SIMD2 {
    var json: String {
        "\(x), \(y)".parenthesized.quoted
    }
}

extension SIMD3 {
    var json: String {
        "\(x), \(y), \(z)".parenthesized.quoted
    }
}

extension SIMD4 {
    var json: String {
        "\(x), \(y), \(z), \(w)".parenthesized.quoted
    }
}

extension SIMD8 {
    var json: String {
        (0..<8)
            .map({ "\(self[$0])" })
            .joined(separator: ", ")
            .parenthesized
            .quoted
    }
}

extension String {
    var quoted: String {
        "\"" + self + "\""
    }

    var parenthesized: String {
        "(" + self + ")"
    }
}

extension Array {
    var json: String {
        "[" + map({ "\($0)" }).joined(separator: ", ") + "]"
    }
}
