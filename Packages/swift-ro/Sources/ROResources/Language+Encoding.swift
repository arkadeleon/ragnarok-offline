//
//  Language+Encoding.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/26.
//

import Foundation

extension Locale.Language {
    var preferredEncoding: String.Encoding {
        let cfEncoding = switch languageCode {
        case .arabic:
            CFStringConvertWindowsCodepageToEncoding(1256)
        case .chinese where script == .hanSimplified:
            CFStringConvertWindowsCodepageToEncoding(936)
        case .chinese where script == .hanTraditional:
            CFStringConvertWindowsCodepageToEncoding(950)
        case .japanese:
            CFStringConvertWindowsCodepageToEncoding(932)
        case .korean:
            CFStringConvertWindowsCodepageToEncoding(949)
        case .russian:
            CFStringConvertWindowsCodepageToEncoding(1251)
        case .spanish where region == .latinAmerica:
            CFStringConvertWindowsCodepageToEncoding(1145)
        case .thai:
            CFStringConvertWindowsCodepageToEncoding(874)
        case .vietnamese:
            CFStringConvertWindowsCodepageToEncoding(1258)
        default:
            CFStringConvertWindowsCodepageToEncoding(1252)
        }

        let nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
        let encoding = String.Encoding(rawValue: nsEncoding)
        return encoding
    }
}
