//
//  PathFinder.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/6/17.
//

private let maxWalkPath = 32
private let maxRequestPathLength = 32
private let maxRequestPathLengthWithoutStraightLine = 14

private let moveCost = 10
private let diagonalMoveCost = 14

final class PathFinder {
    let mapGrid: MapGrid

    init(mapGrid: MapGrid) {
        self.mapGrid = mapGrid
    }

    func findPath(from start: SIMD2<Int>, to end: SIMD2<Int>) -> [SIMD2<Int>] {
        guard isPassable(end.x, end.y) else {
            return []
        }

        return searchPath(from: start, to: end, range: 0)
    }

    func findPath(from start: SIMD2<Int>, to end: SIMD2<Int>, within range: Int) -> [SIMD2<Int>] {
        searchPath(from: start, to: end, range: max(range, 0))
    }

    private func searchPath(from start: SIMD2<Int>, to end: SIMD2<Int>, range: Int) -> [SIMD2<Int>] {
        guard (0..<mapGrid.width).contains(start.x),
              (0..<mapGrid.height).contains(start.y) else {
            return []
        }

        var search = PathSearch()

        let startIndex = PathSearch.index(x: start.x, y: start.y)
        search.nodes[startIndex] = PathSearch.Node(
            x: start.x,
            y: start.y,
            gCost: 0,
            fCost: heuristic(start.x, start.y, end),
            parent: nil,
            isClosed: false
        )
        search.push(startIndex)

        while true {
            guard let current = search.pop() else {
                return []
            }

            search.nodes[current].isClosed = true

            let x = search.nodes[current].x
            let y = search.nodes[current].y
            let gCost = search.nodes[current].gCost

            if isWithinRange(SIMD2(x, y), of: end, range: range) {
                return reconstructPath(search: search, endIndex: current)
            }

            let canMoveNorth = isPassable(x, y + 1)
            let canMoveSouth = isPassable(x, y - 1)
            let canMoveEast = isPassable(x + 1, y)
            let canMoveWest = isPassable(x - 1, y)

            let neighbors: [(dx: Int, dy: Int, isAllowed: Bool)] = [
                (1, -1, canMoveSouth && canMoveEast && isPassable(x + 1, y - 1)),
                (1, 0, canMoveEast),
                (1, 1, canMoveNorth && canMoveEast && isPassable(x + 1, y + 1)),
                (0, 1, canMoveNorth),
                (-1, 1, canMoveNorth && canMoveWest && isPassable(x - 1, y + 1)),
                (-1, 0, canMoveWest),
                (-1, -1, canMoveSouth && canMoveWest && isPassable(x - 1, y - 1)),
                (0, -1, canMoveSouth),
            ]

            for (dx, dy, isAllowed) in neighbors where isAllowed {
                let cost = (dx != 0 && dy != 0) ? diagonalMoveCost : moveCost
                let isAdded = search.addNode(
                    x: x + dx,
                    y: y + dy,
                    gCost: gCost + cost,
                    hCost: heuristic(x + dx, y + dy, end),
                    parent: current
                )
                guard isAdded else {
                    return []
                }
            }
        }
    }

    func canRequestMove(from start: SIMD2<Int>, to end: SIMD2<Int>) -> Bool {
        let path = findPath(from: start, to: end)
        guard !path.isEmpty else {
            return false
        }

        let length = path.count - 1
        guard length <= maxRequestPathLength else {
            return false
        }

        return length <= maxRequestPathLengthWithoutStraightLine || canMoveStraight(from: start, to: end)
    }

    func canMoveStraight(from start: SIMD2<Int>, to end: SIMD2<Int>) -> Bool {
        var x0 = start.x
        var y0 = start.y
        var x1 = end.x
        var y1 = end.y

        var dx = x1 - x0
        if dx < 0 {
            swap(&x0, &x1)
            swap(&y0, &y1)
            dx = -dx
        }
        let dy = y1 - y0

        let weight = dx > abs(dy) ? dx : abs(dy)
        var wx = 0
        var wy = 0

        while x0 != x1 || y0 != y1 {
            wx += dx
            wy += dy
            if wx >= weight {
                wx -= weight
                x0 += 1
            }
            if wy >= weight {
                wy -= weight
                y0 += 1
            } else if wy < 0 {
                wy += weight
                y0 -= 1
            }
            if (x0 != x1 || y0 != y1) && !isPassable(x0, y0) {
                return false
            }
        }

        return true
    }

    private func isPassable(_ x: Int, _ y: Int) -> Bool {
        guard x >= 0 && x < mapGrid.width - 1 && y >= 0 && y < mapGrid.height - 1 else {
            return false
        }

        return mapGrid[SIMD2(x, y)].isWalkable
    }

    private func heuristic(_ x: Int, _ y: Int, _ end: SIMD2<Int>) -> Int {
        moveCost * (abs(end.x - x) + abs(end.y - y))
    }

    private func isWithinRange(_ position: SIMD2<Int>, of target: SIMD2<Int>, range: Int) -> Bool {
        max(abs(target.x - position.x), abs(target.y - position.y)) <= range
    }

    private func reconstructPath(search: PathSearch, endIndex: Int) -> [SIMD2<Int>] {
        var path: [SIMD2<Int>] = []
        var index: Int? = endIndex
        while let currentIndex = index {
            let node = search.nodes[currentIndex]
            path.append(SIMD2(node.x, node.y))
            index = node.parent
        }

        guard path.count - 1 <= maxWalkPath else {
            return []
        }

        return path.reversed()
    }
}

private struct PathSearch {
    struct Node {
        var x = 0
        var y = 0
        var gCost = 0
        var fCost = 0
        var parent: Int?
        var isClosed = false
    }

    static func index(x: Int, y: Int) -> Int {
        (x + y * maxWalkPath) & (maxWalkPath * maxWalkPath - 1)
    }

    var nodes = [PathSearch.Node](repeating: PathSearch.Node(), count: maxWalkPath * maxWalkPath)
    var heap: [Int] = []

    mutating func addNode(x: Int, y: Int, gCost: Int, hCost: Int, parent: Int) -> Bool {
        let index = PathSearch.index(x: x, y: y)

        if nodes[index].x == x && nodes[index].y == y {
            if gCost < nodes[index].gCost {
                nodes[index].gCost = gCost
                nodes[index].parent = parent
                nodes[index].fCost = gCost + hCost
                if nodes[index].isClosed {
                    push(index)
                } else if !update(index) {
                    return false
                }
                nodes[index].isClosed = false
            }
            return true
        }

        if nodes[index].x != 0 || nodes[index].y != 0 {
            return false
        }

        nodes[index] = PathSearch.Node(
            x: x,
            y: y,
            gCost: gCost,
            fCost: gCost + hCost,
            parent: parent,
            isClosed: false
        )
        push(index)
        return true
    }

    mutating func push(_ node: Int) {
        heap.append(node)
        moveUp(from: heap.count - 1, toward: 0)
    }

    mutating func pop() -> Int? {
        guard let top = heap.first else {
            return nil
        }

        let last = heap.removeLast()
        if !heap.isEmpty {
            heap[0] = last
            moveDown(from: 0)
        }
        return top
    }

    private mutating func update(_ node: Int) -> Bool {
        guard let index = heap.firstIndex(of: node) else {
            return false
        }

        moveUp(from: index, toward: 0)
        moveDown(from: index)
        return true
    }

    private mutating func moveUp(from index: Int, toward startIndex: Int) {
        var i = index
        while i > startIndex {
            let parent = (i - 1) / 2
            if compare(heap[parent], heap[i]) <= 0 {
                break
            }
            heap.swapAt(parent, i)
            i = parent
        }
    }

    private mutating func moveDown(from index: Int) {
        var i = index
        var left = i * 2 + 1
        while left < heap.count {
            let right = i * 2 + 2
            if right >= heap.count || compare(heap[left], heap[right]) < 0 {
                heap.swapAt(i, left)
                i = left
            } else {
                heap.swapAt(i, right)
                i = right
            }
            left = i * 2 + 1
        }
        moveUp(from: i, toward: index)
    }

    private func compare(_ lhs: Int, _ rhs: Int) -> Int {
        nodes[lhs].fCost - nodes[rhs].fCost
    }
}
