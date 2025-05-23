// The Swift Programming Language
// https://docs.swift.org/swift-book

import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import rAthenaResources

enum ServerError: Error {
    case stopped
}

try ServerResourceManager.default.prepareWorkingDirectory()

await withThrowingTaskGroup { taskGroup in
    taskGroup.addTask {
        let loginServer = LoginServer()

        await loginServer.start()

        for await status in loginServer.publisher(for: \.status).values {
            if status == .stopped {
                throw ServerError.stopped
            }
        }
    }

    taskGroup.addTask {
        let charServer = CharServer()

        await charServer.start()

        for await status in charServer.publisher(for: \.status).values {
            if status == .stopped {
                throw ServerError.stopped
            }
        }
    }

    taskGroup.addTask {
        let mapServer = MapServer()

        await mapServer.start()

        for await status in mapServer.publisher(for: \.status).values {
            if status == .stopped {
                throw ServerError.stopped
            }
        }
    }

    taskGroup.addTask {
        let webServer = WebServer()

        await webServer.start()

        for await status in webServer.publisher(for: \.status).values {
            if status == .stopped {
                throw ServerError.stopped
            }
        }
    }
}
