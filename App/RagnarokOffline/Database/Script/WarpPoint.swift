//
//  WarpPoint.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/8.
//

/// Define a warp point.
///
/// `<from mapname>,<fromX>,<fromY>,<facing>%TAB%warp%TAB%<warp name>%TAB%<spanx>,<spany>,<to mapname>,<toX>,<toY>`
/// `<from mapname>,<fromX>,<fromY>,<facing>%TAB%warp2%TAB%<warp name>%TAB%<spanx>,<spany>,<to mapname>,<toX>,<toY>`
/// `<from mapname>,<fromX>,<fromY>,<facing>%TAB%warp(<state>)%TAB%<warp name>%TAB%<spanx>,<spany>,<to mapname>,<toX>,<toY>`
/// `<from mapname>,<fromX>,<fromY>,<facing>%TAB%warp2(<state>)%TAB%<warp name>%TAB%<spanx>,<spany>,<to mapname>,<toX>,<toY>`
public struct WarpPoint {

    public var fromMapName: String

    public var fromX: Int

    public var fromY: Int

    public var facing: Int

    public var warpName: String

    public var spanX: Int

    public var spanY: Int

    public var toMapName: String

    public var toX: Int

    public var toY: Int

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        let column1 = w1.split(separator: ",")
        let column4 = w4.split(separator: ",")

        fromMapName = String(column1[0])
        fromX = Int(column1[1])!
        fromY = Int(column1[2])!
        facing = Int(column1[3])!

        warpName = w3

        spanX = Int(column4[0])!
        spanY = Int(column4[1])!
        toMapName = String(column4[2])
        toX = Int(column4[3])!
        toY = Int(column4[4])!
    }
}
