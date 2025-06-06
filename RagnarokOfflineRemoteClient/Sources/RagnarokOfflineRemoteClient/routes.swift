import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: ClientController(resourcesDirectory: app.directory.resourcesDirectory))
}
