//
//  LUADocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/9.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class LUADocument: Document {

    let source: DocumentSource

    required init(source: DocumentSource) {
        self.source = source
    }

    func load(from data: Data) -> Result<String, DocumentError> {
        guard let string = String(data: data, encoding: .ascii) else {
            return .failure(.invalidContents)
        }

        return .success(string)
    }
}
