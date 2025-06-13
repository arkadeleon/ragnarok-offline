//
//  ANSIColor.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/24.
//

import Foundation
import SwiftUI

enum ANSIColor: String, CaseIterable {
    case reset = "\u{001B}[0m"
    case cls = "\u{001B}[2J"
    case cll = "\u{001B}[K"
    case bold = "\u{001B}[1m"
    case white = "\u{001B}[1;37m"
    case gray = "\u{001B}[1;30m"
    case red = "\u{001B}[1;31m"
    case green = "\u{001B}[1;32m"
    case yellow = "\u{001B}[1;33m"
    case blue = "\u{001B}[1;34m"
    case magenta = "\u{001B}[1;35m"
    case cyan = "\u{001B}[1;36m"
}

extension AttributedString {
    init(logMessage: String) {
        typealias Match = (range: Range<String.Index>, ansiColor: ANSIColor)

        var matches: [Match] = []

        for ansiColor in ANSIColor.allCases {
            let ranges = logMessage.ranges(of: ansiColor.rawValue)
            for range in ranges {
                matches.append((range, ansiColor))
            }
        }

        matches.sort(using: KeyPathComparator(\.range.lowerBound))

        var attributes = AttributeContainer()
        attributes.font = .caption.monospaced()
        attributes.foregroundColor = .primary

        if matches.isEmpty {
            self.init(logMessage, attributes: attributes)
        } else {
            self.init()

            for i in -1..<matches.count {
                let startIndex: String.Index
                let endIndex: String.Index

                if i == -1 {
                    startIndex = logMessage.startIndex
                } else {
                    startIndex = matches[i].range.upperBound
                }

                if i == matches.count - 1 {
                    endIndex = logMessage.endIndex
                } else {
                    endIndex = matches[i + 1].range.lowerBound
                }

                if i != -1 {
                    attributes.update(by: matches[i].ansiColor)
                }

                let substring = logMessage[startIndex..<endIndex]
                let attributedSubstring = AttributedString(substring, attributes: attributes)
                append(attributedSubstring)
            }
        }
    }
}

extension AttributeContainer {
    mutating func update(by ansiColor: ANSIColor) {
        switch ansiColor {
        case .reset:
            self.font = .caption.monospaced()
            self.foregroundColor = .primary
        case .cls:
            self.font = .caption.monospaced()
            self.foregroundColor = .primary
        case .cll:
            self.font = .caption.monospaced()
            self.foregroundColor = .primary
        case .bold:
            self.font = .caption.monospaced().bold()
        case .white:
            self.foregroundColor = .primary
        case .gray:
            self.foregroundColor = .gray
        case .red:
            self.foregroundColor = .red
        case .green:
            self.foregroundColor = .green
        case .yellow:
            self.foregroundColor = .yellow
        case .blue:
            self.foregroundColor = .blue
        case .magenta:
            self.foregroundColor = .red
        case .cyan:
            self.foregroundColor = .cyan
        }
    }
}
