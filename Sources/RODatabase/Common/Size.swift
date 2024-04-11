//
//  Size.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum Size: String, CaseIterable, CodingKey, Decodable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

extension Size: Identifiable {
    public var id: Int {
        switch self {
        case .small: RA_SZ_SMALL
        case .medium: RA_SZ_MEDIUM
        case .large: RA_SZ_BIG
        }
    }
}

extension Size: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
