//
//  ConsoleColor.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/24.
//

import Foundation
import SwiftUI

enum ConsoleColor: String, CaseIterable {
    case RESET = "\u{001B}[0m"
    case CLS = "\u{001B}[2J"
    case CLL = "\u{001B}[K"
    case BOLD = "\u{001B}[1m"
    case WHITE = "\u{001B}[1;37m"
    case GRAY = "\u{001B}[1;30m"
    case RED = "\u{001B}[1;31m"
    case GREEN = "\u{001B}[1;32m"
    case YELLOW = "\u{001B}[1;33m"
    case BLUE = "\u{001B}[1;34m"
    case MAGENTA = "\u{001B}[1;35m"
    case CYAN = "\u{001B}[1;36m"

    var uiColor: Color {
        switch self {
        case .RESET: .primary
        case .CLS: .primary
        case .CLL: .primary
        case .BOLD: .primary
        case .WHITE: .primary
        case .GRAY: .gray
        case .RED: .red
        case .GREEN: .green
        case .YELLOW: .yellow
        case .BLUE: .blue
        case .MAGENTA: .red
        case .CYAN: .cyan
        }
    }
}

struct Match {
    var range: Range<String.Index>
    var color: ConsoleColor
}

func attributedStringForServerOutput(_ string: String) -> AttributedString {
    var matches: [Match] = []

    for color in ConsoleColor.allCases {
        let ranges = string.ranges(of: color.rawValue)
        for range in ranges {
            let match = Match(range: range, color: color)
            matches.append(match)
        }
    }

    matches.sort(using: KeyPathComparator(\.range.lowerBound))

    if matches.isEmpty {
        return AttributedString(string)
    }

    var attributedString = AttributedString()

    for i in 0..<matches.count {
        if i != matches.count - 1 {
            let start = matches[i].range.upperBound
            let end = matches[i + 1].range.lowerBound
            let substring = string[start..<end]
            var attributedSubstring = AttributedString(substring)
            attributedSubstring[attributedSubstring.startIndex..<attributedSubstring.endIndex].foregroundColor = matches[i].color.uiColor
            attributedString.append(attributedSubstring)
        } else {
            let start = matches[i].range.upperBound
            let end = string.endIndex
            let substring = string[start..<end]
            var attributedSubstring = AttributedString(substring)
            attributedSubstring[attributedSubstring.startIndex..<attributedSubstring.endIndex].foregroundColor = matches[i].color.uiColor
            attributedString.append(attributedSubstring)
        }
    }

    return attributedString
}
