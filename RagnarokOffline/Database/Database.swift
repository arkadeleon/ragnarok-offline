//
//  Database.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/1/12.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

class Database {

    private let connection: Connection

    static let client: Database = {
        let path = Bundle.main.path(forResource: "client", ofType: "sqlite3")!
        let connection = try! Connection(path)
        return Database(connection: connection)
    }()

    init(connection: Connection) {
        self.connection = connection
    }
}
