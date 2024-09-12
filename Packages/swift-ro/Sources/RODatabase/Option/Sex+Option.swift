//
//  Sex+Option.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import ROGenerated

extension Sex: Option {
    public var stringValue: String {
        switch self {
        case .female: "Female"
        case .male: "Male"
        case .both: "Both"
        }
    }
}
