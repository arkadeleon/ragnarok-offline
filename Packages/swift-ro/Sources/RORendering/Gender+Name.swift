//
//  Gender+Name.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/8.
//

import ROGenerated

extension Gender {
    var name: String {
        switch self {
        case .female: "여"
        case .male: "남"
        case .both: ""
        }
    }
}
