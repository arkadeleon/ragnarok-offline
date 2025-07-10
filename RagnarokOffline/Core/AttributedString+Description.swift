//
//  AttributedString+Description.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/10.
//

import SwiftUI

extension AttributedString {
    init(description: String) {
        var description = description

        let regex = /\^[a-fA-F0-9]{6}/
        let matches = description.matches(of: regex)

        for match in matches.reversed() {
            let colorString = String(description[match.range])
            description.replaceSubrange(match.range, with: "[COLOR]" + colorString + "[COLOR]")
        }

        let substrings = description.split(separator: "[COLOR]")

        var attributedString = AttributedString()
        var color = Color.primary

        for substring in substrings {
            if substring.contains(regex) {
                let hexString = substring.replacingOccurrences(of: "^", with: "")
                if let hexValue = Int(hexString, radix: 16) {
                    if hexValue == 0 {
                        color = .primary
                    } else {
                        color = Color(hex: hexValue)
                    }
                }
            } else {
                var attributedSubstring = AttributedString(substring)
                attributedSubstring.foregroundColor = color
                attributedString.append(attributedSubstring)
            }
        }

        self = attributedString
    }
}

extension Color {
    init(hex: Int) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self = Color(red: red, green: green, blue: blue)
    }
}
