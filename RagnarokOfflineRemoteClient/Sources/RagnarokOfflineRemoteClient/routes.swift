import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: ClientController(resourcesDirectory: app.directory.resourcesDirectory))
    try app.register(collection: GRFController(resourcesDirectory: app.directory.resourcesDirectory))
}
