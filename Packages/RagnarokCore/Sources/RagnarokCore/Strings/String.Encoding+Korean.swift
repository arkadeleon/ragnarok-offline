//
//  String.Encoding+Korean.swift
//  RagnarokCore
//
//  Created by Leon Li on 2023/4/8.
//

import Foundation

extension String.Encoding {
    public static let dosKorean: String.Encoding = {
        let cfStringEncoding = CFStringEncoding(CFStringEncodings.dosKorean.rawValue)
        let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
        let stringEncoding = String.Encoding(rawValue: nsStringEncoding)
        return stringEncoding
    }()
}
