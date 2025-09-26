//
//  String+Transcoding.swift
//  TextEncoding
//
//  Created by Leon Li on 2024/4/1.
//

import Foundation

/// Converts a string from Korean EUC encoding to ISO Latin-1 encoding.
public func K2L(_ k: String) -> String {
    k.transcoding(from: .koreanEUC, to: .isoLatin1) ?? k
}

/// Converts a string from ISO Latin-1 encoding to Korean EUC encoding.
public func L2K(_ l: String) -> String {
    l.transcoding(from: .isoLatin1, to: .koreanEUC) ?? l
}

extension StringProtocol {
    public func transcoding(from fromEncoding: String.Encoding, to toEncoding: String.Encoding) -> String? {
        data(using: fromEncoding).flatMap { data in
            String(data: data, encoding: toEncoding)
        }
    }
}
