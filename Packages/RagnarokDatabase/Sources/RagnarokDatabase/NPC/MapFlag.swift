//
//  MapFlag.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/8.
//

/// Define a map flag.
///
/// `<map name>%TAB%mapflag%TAB%<flag>`
/// `<map name>%TAB%mapflag%TAB%<flag>%TAB%<value>`
public struct MapFlag: Sendable {

    /// Map name.
    public var mapName: String

    /// Map flag.
    public var flag: String

    /// Map flag value, e.g. `off`, `SavePoint` or `HT_LANDMINE,400`. `nil` if not specified.
    public var value: String?

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        mapName = w1
        flag = w3
        value = w4.isEmpty ? nil : w4
    }
}
