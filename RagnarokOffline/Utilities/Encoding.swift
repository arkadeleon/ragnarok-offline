//
//  Encoding.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/8.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

enum Encoding: CaseIterable {

    case ascii
    case gb_18030_2000
    case euc_kr

    var name: String {
        switch self {
        case .ascii:
            return "ASCII"
        case .gb_18030_2000:
            return "GB 18030"
        case .euc_kr:
            return "EUC-KR"
        }
    }

    var cfStringEncoding: CFStringEncoding {
        switch self {
        case .ascii:
            return CFStringBuiltInEncodings.ASCII.rawValue
        case .gb_18030_2000:
            return CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
        case .euc_kr:
            return CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
        }
    }

    var nsStringEncoding: UInt {
        CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
    }

    var swiftStringEncoding: String.Encoding {
        String.Encoding(rawValue: nsStringEncoding)
    }
}

extension String.Encoding {
    static var koreanEUC: Self {
        Encoding.euc_kr.swiftStringEncoding
    }
}
