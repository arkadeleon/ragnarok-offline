//
//  Character.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/8.
//

//import RODatabase
//
//struct Character {
//
//    enum Sex: Int {
//        case female = 0
//        case male = 1
//
//        var resourceName: String {
//            switch self {
//            case .female: "여"
//            case .male: "남"
//            }
//        }
//    }
//
//    enum Action {
//        case idle
//        case attack
//
//        case walk
//        case sit
//        case pickup
//        case readyFight
//        case freeze
//        case hurt
//        case die
//        case freeze2
//        case attack1
//        case attack2
//        case attack3
//        case skill
//        case action
//
//        case special
//        case perf1
//        case perf2
//        case perf3
//    }
//
//    enum Direction: Int {
//        case south = 0
//        case southwest = 1
//        case west = 2
//        case northwest = 3
//        case north = 4
//        case northeast = 5
//        case esat = 6
//        case southeast = 7
//    }
//
//    var sex: Sex?
//    var job: Int
//
//    var direction: Direction
//    var headDirection: Direction
//
//    var action: Action
//
//    var actions: [Action] {
//        return [
//            .idle,
//            .walk,
//            .sit,
//            .pickup,
//            .readyFight,
//            .attack1,
//            .hurt,
//            .freeze,
//            .die,
//            .freeze2,
//            .attack2,
//            .attack3,
//            .skill
//        ]
//    }
//
//    init() {
//        job = Job.novice.id
//
//        direction = .south
//        headDirection = .south
//
//        action = .idle
//    }
//}
