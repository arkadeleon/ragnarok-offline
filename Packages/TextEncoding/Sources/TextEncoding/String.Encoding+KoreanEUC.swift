//
//  String.Encoding+KoreanEUC.swift
//  TextEncoding
//
//  Created by Leon Li on 2023/4/8.
//

import Foundation

extension String.Encoding {
    public static let koreanEUC: String.Encoding = {
        let cfStringEncoding = CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
        let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
        let stringEncoding = String.Encoding(rawValue: nsStringEncoding)
        return stringEncoding
    }()
}
