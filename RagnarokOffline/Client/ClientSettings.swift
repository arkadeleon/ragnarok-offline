//
//  ClientSettings.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation

class ClientSettings {
    static let shared = ClientSettings()

    private let serviceTypeKey = "client.service_type"

    var serviceType: ServiceType {
        didSet {
            UserDefaults.standard.setValue(serviceType.rawValue, forKey: serviceTypeKey)
        }
    }

    init() {
        serviceType = UserDefaults.standard.string(forKey: serviceTypeKey).flatMap(ServiceType.init) ?? .korea
    }
}

extension ClientSettings {
    enum ServiceType: String, CaseIterable {
        case korea = "Korea"
        case america = "America"
        case japan = "Japan"
        case china = "China"
        case taiwan = "Taiwan"
        case thai = "Thai"
        case indonesia = "Indonesia"
        case philippine = "Philippine"
        case malaysia = "Malaysia"
        case singapore = "Singapore"
        case germany = "Germany"
        case india = "India"
        case brazil = "Brazil"
        case australia = "Australia"
        case russia = "Russia"
        case vietnam = "Vietnam"
        case chile = "Chile"
        case france = "France"
        case uae = "UAE"

        var stringEncoding: String.Encoding {
            let cfStringEncoding = switch self {
            case .america, .indonesia, .philippine, .malaysia, .singapore, .germany, .india, .brazil, .australia, .france:
                CFStringConvertWindowsCodepageToEncoding(1252)
            case .korea:
                CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
            case .japan:
                CFStringEncoding(CFStringEncodings.shiftJIS.rawValue)
            case .china:
                CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
            case .taiwan:
                CFStringEncoding(CFStringEncodings.GB_2312_80.rawValue)
            case .thai:
                CFStringConvertWindowsCodepageToEncoding(874)
            case .russia:
                CFStringConvertWindowsCodepageToEncoding(1251)
            case .vietnam:
                CFStringConvertWindowsCodepageToEncoding(1258)
            case .chile:
                CFStringConvertWindowsCodepageToEncoding(1145)
            case .uae:
                CFStringConvertWindowsCodepageToEncoding(1256)
            }

            let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
            let stringEncoding = String.Encoding(rawValue: nsStringEncoding)
            return stringEncoding
        }
    }
}
