//
//  TextEncoding.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/8.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

enum TextEncoding: String, CaseIterable {
    case `default` = "Default"
    case simplifiedChinese = "Simplified Chinese"
    case japanese = "Japanese"
    case korean = "Korean"

    var cfStringEncoding: CFStringEncoding {
        switch self {
        case .default:
            return CFStringBuiltInEncodings.ASCII.rawValue
        case .simplifiedChinese:
            return CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
        case .japanese:
            return CFStringEncoding(CFStringEncodings.shiftJIS.rawValue)
        case .korean:
            return CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
        }
    }

    var nsStringEncoding: UInt {
        CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
    }

    var stringEncoding: String.Encoding {
        String.Encoding(rawValue: nsStringEncoding)
    }
}

extension String.Encoding {
    static var koreanEUC: Self {
        TextEncoding.korean.stringEncoding
    }
}
