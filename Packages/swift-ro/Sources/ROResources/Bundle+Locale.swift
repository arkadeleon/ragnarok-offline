//
//  Bundle+Locale.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

extension Bundle {
    func url(forResource name: String?, withExtension ext: String?, locale: Locale) -> URL? {
        let localization = Bundle.preferredLocalizations(from: localizations, forPreferences: [locale.identifier])[0]
        return url(forResource: name, withExtension: ext, subdirectory: nil, localization: localization)
    }

    func string(forResource name: String?, withExtension ext: String?, encoding enc: String.Encoding, locale: Locale) -> String? {
        guard let url = url(forResource: name, withExtension: ext, locale: locale) else {
            return nil
        }

        let string = try? String(contentsOf: url, encoding: enc)
        return string
    }
}
