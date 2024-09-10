//
//  ResourceBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import CoreGraphics
import Foundation
import ROCore

public let resourceBundle = Bundle.module

extension Bundle {
    public func url(forResource name: String?, withExtension ext: String?, locale: Locale) -> URL? {
        let localization = Bundle.preferredLocalizations(from: localizations, forPreferences: [locale.identifier])[0]
        return url(forResource: name, withExtension: ext, subdirectory: nil, localization: localization)
    }

    public func data(forResource name: String?, withExtension ext: String?, locale: Locale) -> Data? {
        guard let url = url(forResource: name, withExtension: ext, locale: locale) else {
            return nil
        }

        let data = try? Data(contentsOf: url)
        return data
    }

    public func string(forResource name: String?, withExtension ext: String?, encoding enc: String.Encoding, locale: Locale) -> String? {
        guard let url = url(forResource: name, withExtension: ext, locale: locale) else {
            return nil
        }

        let string = try? String(contentsOf: url, encoding: enc)
        return string
    }

    public func image(forResource name: String?, withExtension ext: String?, locale: Locale) -> CGImage? {
        guard let data = data(forResource: name, withExtension: ext, locale: locale) else {
            return nil
        }

        let image = CGImageCreateWithData(data)?.removingMagentaPixels()
        return image
    }
}
