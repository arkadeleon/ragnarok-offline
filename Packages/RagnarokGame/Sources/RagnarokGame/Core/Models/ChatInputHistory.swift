//
//  ChatInputHistory.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/22.
//

struct ChatInputHistory {
    static let capacity = 50

    private(set) var messages: [String] = []
    private(set) var index = 0

    var hasPrevious: Bool {
        index > 0
    }

    var hasNext: Bool {
        index < messages.count
    }

    mutating func push(_ message: String) {
        if messages.last != message {
            if messages.count >= ChatInputHistory.capacity {
                messages.removeFirst()
            }
            messages.append(message)
        }

        index = messages.count
    }

    mutating func previous() -> String {
        if hasPrevious {
            index -= 1
        }
        return messages.indices.contains(index) ? messages[index] : ""
    }

    mutating func next() -> String {
        if hasNext {
            index += 1
        }
        return messages.indices.contains(index) ? messages[index] : ""
    }
}
