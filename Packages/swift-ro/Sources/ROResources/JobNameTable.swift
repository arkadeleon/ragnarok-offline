//
//  JobNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public let jobNameTable = JobNameTable()

public actor JobNameTable {
    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "npcidentity", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "jobname", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            try context.parse("""
            function jobName(jobID)
                return JobNameTable[jobID]
            end
            """)
        } catch {
            print(error)
        }

        return context
    }()

    public func jobName(forJobID jobID: Int) -> String? {
        let result = try? context.call("jobName", with: [jobID]) as? String
        return result
    }
}
