//
//  Bundle+Locale.swift
//  ResourceManagement
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

extension Bundle {
    func url(forResource name: String?, withExtension ext: String?, locale: Locale) -> URL? {
        let localization = Bundle.preferredLocalizations(from: localizations, forPreferences: [locale.identifier])[0]
        return url(forResource: name, withExtension: ext, subdirectory: nil, localization: localization)
    }
}
