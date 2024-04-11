//
//  ClientSettings.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import Foundation

public class ClientSettings {
    public static let shared = ClientSettings()

    @SettingsItem("client.service_type", defaultValue: .korea) public var serviceType: ServiceType
    @SettingsItem("client.item_info_source", defaultValue: .lua) public var itemInfoSource: ItemInfoSource
}

extension ClientSettings {
    public enum ServiceType: String, CaseIterable, CustomStringConvertible {
        case korea
        case america
        case japan
        case china
        case taiwan
        case thai
        case indonesia
        case philippine
        case malaysia
        case singapore
        case germany
        case india
        case brazil
        case australia
        case russia
        case vietnam
        case chile
        case france
        case uae

        public var description: String {
            switch self {
            case .korea: "Korea"
            case .america: "America"
            case .japan: "Japan"
            case .china: "China"
            case .taiwan: "Taiwan"
            case .thai: "Thai"
            case .indonesia: "Indonesia"
            case .philippine: "Philippine"
            case .malaysia: "Malaysia"
            case .singapore: "Singapore"
            case .germany: "Germany"
            case .india: "India"
            case .brazil: "Brazil"
            case .australia: "Australia"
            case .russia: "Russia"
            case .vietnam: "Vietnam"
            case .chile: "Chile"
            case .france: "France"
            case .uae: "UAE"
            }
        }

        public var stringEncoding: String.Encoding {
            let cfStringEncoding = switch self {
            case .america, .indonesia, .philippine, .malaysia, .singapore, .germany, .india, .brazil, .australia, .france:
                CFStringConvertWindowsCodepageToEncoding(1252)
            case .korea:
                CFStringConvertWindowsCodepageToEncoding(949)
            case .japan:
                CFStringConvertWindowsCodepageToEncoding(932)
            case .china:
                CFStringConvertWindowsCodepageToEncoding(936)
            case .taiwan:
                CFStringConvertWindowsCodepageToEncoding(950)
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

extension ClientSettings {
    public enum ItemInfoSource: String, CaseIterable, CustomStringConvertible {
        case lua
        case txt

        public var description: String {
            switch self {
            case .lua: "Lua"
            case .txt: "Text"
            }
        }
    }
}
