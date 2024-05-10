//
//  MapFlag.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/8.
//

/// Define a map flag.
///
/// `<map name>%TAB%mapflag%TAB%<flag>`
public struct MapFlag {

    /// Map name.
    public var mapName: String

    /// Map flag.
    public var flag: String

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String?) {
        mapName = w1
        flag = w3
    }
}
