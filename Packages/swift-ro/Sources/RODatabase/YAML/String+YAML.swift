//
//  String+YAML.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/19.
//

import Foundation
import ryml

extension c4.csubstr {
    var string: String {
        let data = Data(bytes: str, count: len)
        let string = String(data: data, encoding: .utf8)
        return string ?? ""
    }
}

extension String {
    var csubstr: c4.csubstr {
        let csubstr = withCString { string in
            c4.to_csubstr(string)
        }
        return csubstr
    }
}
