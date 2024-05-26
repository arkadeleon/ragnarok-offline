//
//  Locale+StringEncoding.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/26.
//

import Foundation

extension Locale {
    var stringEncoding: String.Encoding {
        let cfStringEncoding: CFStringEncoding
        if language.languageCode == .korean {
            cfStringEncoding = CFStringConvertWindowsCodepageToEncoding(949)
        } else if language.languageCode == .japanese {
            cfStringEncoding = CFStringConvertWindowsCodepageToEncoding(932)
        } else if language.languageCode == .chinese && language.script == .hanSimplified {
            cfStringEncoding = CFStringConvertWindowsCodepageToEncoding(936)
        } else if language.languageCode == .chinese && language.script == .hanTraditional {
            cfStringEncoding = CFStringConvertWindowsCodepageToEncoding(950)
        } else if language.languageCode == .thai {
            cfStringEncoding = CFStringConvertWindowsCodepageToEncoding(874)
        } else if language.languageCode == .russian {
            cfStringEncoding = CFStringConvertWindowsCodepageToEncoding(1251)
        } else {
            cfStringEncoding = CFStringConvertWindowsCodepageToEncoding(1252)
        }

        let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
        let stringEncoding = String.Encoding(rawValue: nsStringEncoding)
        return stringEncoding
    }
}
