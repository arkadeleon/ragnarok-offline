//
//  JobNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation
import Lua

public actor JobNameTable {
    public static let current = JobNameTable()

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

            if let url = Bundle.module.url(forResource: "jobname_f", withExtension: "lub") {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        return context
    }()

    public func jobName(forJobID jobID: Int) -> String? {
        let result = try? context.call("ReqJobName", with: [jobID]) as? String
        return result
    }
}
