//
//  Data+String.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/1.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation

extension Data {
    func string(using encoding: String.Encoding) -> String? {
        String(data: self, encoding: encoding)
    }
}
