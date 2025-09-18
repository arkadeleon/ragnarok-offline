//
//  ListNode.swift
//  DatabaseCore
//
//  Created by Leon Li on 2023/1/20.
//

struct ListNode<Element>: Decodable where Element: Decodable {

    /// Header.
    struct Header: Decodable {

        /// Type.
        var type: String

        /// Version.
        var version: Int

        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case version = "Version"
        }
    }

    /// Header.
    var header: Header

    /// Body.
    var body: [Element]

    enum CodingKeys: String, CodingKey {
        case header = "Header"
        case body = "Body"
    }
}
