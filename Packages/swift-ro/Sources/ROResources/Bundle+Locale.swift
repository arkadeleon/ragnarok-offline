//
//  Bundle+Locale.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

extension Bundle {
    func url(forResource name: String?, withExtension ext: String?, locale: Locale) -> URL? {
        if locale == .current {
            return url(forResource: name, withExtension: ext)
        }

        let localization = preferredLocalization(for: locale)
        return url(forResource: name, withExtension: ext, subdirectory: nil, localization: localization)
    }

    func preferredLocalization(for locale: Locale) -> String {
        Bundle.preferredLocalizations(from: localizations, forPreferences: [locale.identifier])[0]
    }
}
