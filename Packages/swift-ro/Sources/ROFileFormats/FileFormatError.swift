//
//  FileFormatError.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/8.
//

import Foundation

public enum FileFormatError: Error {
    case invalidHeader(String, expected: String)
}
