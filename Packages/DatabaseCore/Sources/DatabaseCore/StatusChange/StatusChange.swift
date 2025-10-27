//
//  StatusChange.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/5/10.
//

import RagnarokConstants

public struct StatusChange: Decodable, Equatable, Hashable, Identifiable, Sendable {

    /// Status change name.
    public var status: StatusChangeID

    /// Status change icon. (Default: EFST_BLANK)
    public var icon: OfficialStatusChangeID

    /// Default status change duration. (Default: 0)
    public var durationLookup: String?

    /// Status change state to determine player states. (Default: None)
    public var states: Set<StatusChangeStateFlag>?

    /// Status change calculation to indicate which stat is adjusted. (Default: None)
    public var calcFlags: Set<String>?

    /// Special effect when a status change is active. Non-stackable. (Default: None)
    public var opt1: StatusChangeOption1?

    /// Special options/client effects when a status change is active. (Default: None)
    public var opt2: Set<StatusChangeOption2>?

    /// Special options/client effects when a status change is active. (Default: Normal)
    public var opt3: Set<StatusChangeOption3>?

    /// Special options/client effects when a status change is active. (Default: Nothing)
    public var options: Set<StatusChangeOption>?

    /// Special flags which trigger during certain events.  (Default: None)
    public var flags: Set<String>?

    /// Minimum rate after status change reduction (10000 = 100%). (Default: 0)
    public var minRate: Int

    /// Minimum duration in milliseconds after status change reduction. (Default: 1)
    public var minDuration: Int

    /// List of Status Changes that causes the status to fail to activate. (Optional)
    public var fail: Set<StatusChangeID>?

    /// List of Status Changes that will end when the status activates. (Optional)
    public var endOnStart: Set<StatusChangeID>?

    /// List of Status Changes that will end when the status activates and won't give its effect. (Optional)
    public var endReturn: Set<StatusChangeID>?

    /// List of Status Changes that will end when the status becomes inactive. (Optional)
    public var endOnEnd: Set<StatusChangeID>?

    /// Script to execute, when starting the status change. (Optional)
    public var script: String?

    public var id: StatusChangeID {
        status
    }

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case icon = "Icon"
        case durationLookup = "DurationLookup"
        case states = "States"
        case calcFlags = "CalcFlags"
        case opt1 = "Opt1"
        case opt2 = "Opt2"
        case opt3 = "Opt3"
        case options = "Options"
        case flags = "Flags"
        case minRate = "MinRate"
        case minDuration = "MinDuration"
        case fail = "Fail"
        case endOnStart = "EndOnStart"
        case endReturn = "EndReturn"
        case endOnEnd = "EndOnEnd"
        case script = "Script"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(StatusChangeID.self, forKey: .status)
        self.icon = try container.decodeIfPresent(OfficialStatusChangeID.self, forKey: .icon) ?? .efst_blank
        self.durationLookup = try container.decodeIfPresent(String.self, forKey: .durationLookup)
        self.states = try container.decodeIfPresent([StatusChangeStateFlag : Bool].self, forKey: .states)?.unorderedKeys
        self.calcFlags = try container.decodeIfPresent([String : Bool].self, forKey: .calcFlags).flatMap({ Set<String>($0.keys) })
        self.opt1 = try container.decodeIfPresent(StatusChangeOption1.self, forKey: .opt1)
        self.opt2 = try container.decodeIfPresent([StatusChangeOption2 : Bool].self, forKey: .opt2)?.unorderedKeys
        self.opt3 = try container.decodeIfPresent([StatusChangeOption3 : Bool].self, forKey: .opt3)?.unorderedKeys
        self.options = try container.decodeIfPresent([StatusChangeOption : Bool].self, forKey: .options)?.unorderedKeys
        self.flags = try container.decodeIfPresent([String : Bool].self, forKey: .flags).flatMap({ Set<String>($0.keys) })
        self.minRate = try container.decodeIfPresent(Int.self, forKey: .minRate) ?? 0
        self.minDuration = try container.decodeIfPresent(Int.self, forKey: .minDuration) ?? 1
        self.fail = try container.decodeIfPresent([StatusChangeID : Bool].self, forKey: .fail)?.unorderedKeys
        self.endOnStart = try container.decodeIfPresent([StatusChangeID : Bool].self, forKey: .endOnStart)?.unorderedKeys
        self.endReturn = try container.decodeIfPresent([StatusChangeID : Bool].self, forKey: .endReturn)?.unorderedKeys
        self.endOnEnd = try container.decodeIfPresent([StatusChangeID : Bool].self, forKey: .endOnEnd)?.unorderedKeys
        self.script = try container.decodeIfPresent(String.self, forKey: .script)
    }
}
