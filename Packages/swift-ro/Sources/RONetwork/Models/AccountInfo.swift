//
//  AccountInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/29.
//

public struct AccountInfo: Sendable {
    public let langType: UInt16 = 1

    public internal(set) var accountID: UInt32
    public internal(set) var loginID1: UInt32
    public internal(set) var loginID2: UInt32
    public internal(set) var sex: UInt8
}
