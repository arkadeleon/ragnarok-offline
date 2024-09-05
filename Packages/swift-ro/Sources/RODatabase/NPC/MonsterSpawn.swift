//
//  MonsterSpawn.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/7.
//

/// Define a permanent monster spawn.
///
/// `<map name>{,<x>{,<y>{,<xs>{,<ys>}}}}%TAB%monster%TAB%<monster name>{,<monster level>}%TAB%<mob id>,<amount>{,<delay1>{,<delay2>{,<event>{,<mob size>{,<mob ai>}}}}}`
public struct MonsterSpawn: Sendable {

    /// The name of the map the monsters will spawn on.
    public var mapName: String

    /// The x coordinate where the mob should spawn.
    public var x: Int?

    /// The y coordinate where the mob should spawn.
    public var y: Int?

    /// The x 'radius' of a spawn-rectangle area.
    public var xs: Int?

    /// The y 'radius' of a spawn-rectangle area.
    public var ys: Int?

    /// The name the monster will have on screen.
    public var monsterName: String

    /// The custom level for the monster.
    public var monsterLevel: Int?

    /// Monster ID.
    public var monsterID: Int?

    /// Monster aegis name.
    public var monsterAegisName: String?

    /// The amount of monsters that will be spawned.
    public var amount: Int

    /// Delay1 control the fixed base respawn time.
    public var delay1: Int?

    /// Delay2 is random variance on top of the base time.
    public var delay2: Int?

    /// The script event to be executed when the monster is killed.
    public var event: Int?

    /// Monster size can be:
    /// Size_Small  (0)
    /// Size_Medium (1)
    /// Size_Large  (2)
    public var monsterSize: Int?

    /// Monster AI can be:
    /// AI_NONE     (0) (default)
    /// AI_ATTACK   (1) (attack/friendly)
    /// AI_SPHERE   (2) (Alchemist skill)
    /// AI_FLORA    (3) (Alchemist skill)
    /// AI_ZANZOU   (4) (Kagerou/Oboro skill)
    /// AI_LEGION   (5) (Sera skill)
    /// AI_FAW      (6) (Mechanic skill)
    /// AI_WAVEMODE (7) Normal monsters will ignore attack from AI_WAVEMODE monsters
    public var monsterAI: Int?

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        let column1 = w1.split(separator: ",")
        let column3 = w3.split(separator: ",")
        let column4 = w4.split(separator: ",")

        mapName = String(column1[0])
        x = column1.count > 1 ? Int(column1[1]) : nil
        y = column1.count > 2 ? Int(column1[2]) : nil
        xs = column1.count > 3 ? Int(column1[3]) : nil
        ys = column1.count > 4 ? Int(column1[4]) : nil

        monsterName = String(column3[0])
        monsterLevel = column3.count > 1 ? Int(column3[1]) : nil

        if let sprite = Int(column4[0]) {
            monsterID = sprite
        } else {
            monsterAegisName = String(column4[0])
        }
        amount = Int(column4[1])!
        delay1 = column4.count > 2 ? Int(column4[2]) : nil
        delay2 = column4.count > 3 ? Int(column4[3]) : nil
        event = column4.count > 4 ? Int(column4[4]) : nil
        monsterSize = column4.count > 5 ? Int(column4[5]) : nil
        monsterAI = column4.count > 6 ? Int(column4[6]) : nil
    }
}
