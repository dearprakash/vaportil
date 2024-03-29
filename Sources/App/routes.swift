import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
    let userController = UsersController()
    try router.register(collection: userController)
    let categoriesController = CategoryController()
    try router.register(collection: categoriesController)
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
}
