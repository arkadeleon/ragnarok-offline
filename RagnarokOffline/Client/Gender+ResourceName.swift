//
//  Gender+ResourceName.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/8.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaDatabase

extension Gender {
    var resourceName: String {
        switch self {
        case .female: "여"
        case .male: "남"
        case .both: ""
        }
    }
}
