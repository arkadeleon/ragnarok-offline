//
//  AsyncContentStatus.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

enum AsyncContentStatus<Value> {
    case notYetLoaded
    case loading
    case loaded(Value)
    case failed(Error)
}
