//
//  Dictionary+UnorderedKeys.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/2.
//

extension Dictionary {
    var unorderedKeys: Set<Key> {
        Set(keys)
    }
}
