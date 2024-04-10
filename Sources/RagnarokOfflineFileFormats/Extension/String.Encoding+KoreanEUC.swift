//
//  String.Encoding+KoreanEUC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/8.
//  Copyright © 2023 Leon & Vane. All rights reserved.
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
