//
//  AppTips.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/28.
//

import TipKit

func configureTips() {
    do {
        #if DEBUG
        Tips.showAllTipsForTesting()
        #endif

        try Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    } catch {
        logger.warning("TipKit error: \(error)")
    }
}
