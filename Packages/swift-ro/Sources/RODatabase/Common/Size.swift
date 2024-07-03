//
//  Size.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum Size: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case small
    case medium
    case large

    public var rawValue: Int {
        switch self {
        case .small: RA_SZ_SMALL
        case .medium: RA_SZ_MEDIUM
        case .large: RA_SZ_BIG
        }
    }

    public var stringValue: String {
        switch self {
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        }
    }
}
