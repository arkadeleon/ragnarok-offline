//
//  AnyDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class AnyDocument<Source, Contents>: NSObject {

    let source: Source
    let name: String
    let load: () -> Result<Contents, DocumentError>

    init<D: Document>(document: D) where Source == D.Source, Contents == D.Contents {
        self.source = document.source
        self.name = document.name
        self.load = document.load
        super.init()
    }

    func loadAsynchronously(completionHandler: @escaping (Result<Contents, DocumentError>) -> Void) {
        DispatchQueue.global().async {
            let result = self.load()
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }
}

extension Document {

    func eraseToAnyDocument() -> AnyDocument<Source, Contents> {
        AnyDocument(document: self)
    }
}
