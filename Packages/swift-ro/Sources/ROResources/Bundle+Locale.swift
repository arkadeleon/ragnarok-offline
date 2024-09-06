//
//  Bundle+Locale.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

extension Bundle {
    func data(forResource name: String?, withExtension ext: String?, locale: Locale) -> Data? {
        guard let url = url(forResource: name, withExtension: ext, locale: locale) else {
            return nil
        }

        let data = try? Data(contentsOf: url)
        return data
    }

    func string(forResource name: String?, withExtension ext: String?, encoding enc: String.Encoding, locale: Locale) -> String? {
        guard let url = url(forResource: name, withExtension: ext, locale: locale) else {
            return nil
        }

        let string = try? String(contentsOf: url, encoding: enc)
        return string
    }

    func url(forResource name: String?, withExtension ext: String?, locale: Locale) -> URL? {
        let localization = preferredLocalization(for: locale)
        return url(forResource: name, withExtension: ext, subdirectory: nil, localization: localization)
    }

    func preferredLocalization(for locale: Locale) -> String {
        Bundle.preferredLocalizations(from: localizations, forPreferences: [locale.identifier])[0]
    }
}
