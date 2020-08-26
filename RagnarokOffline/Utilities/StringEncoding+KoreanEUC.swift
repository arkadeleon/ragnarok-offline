//
//  StringEncoding+KoreanEUC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/13.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

extension String.Encoding {

    static var koreanEUC: String.Encoding {
        let cfStringEncoding = CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
        let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
        return String.Encoding(rawValue: nsStringEncoding)
    }
}
