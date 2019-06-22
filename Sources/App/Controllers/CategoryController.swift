
import Vapor

struct CategoryController: RouteCollection {
    func boot(router: Router) throws {
        let categoryRoute = router.grouped("api", "categories")
        categoryRoute.get(use: getAll)
        categoryRoute.post(use: create)
        categoryRoute.get(Category.parameter , use: get)
        categoryRoute.delete(Category.parameter, use: delete)
        categoryRoute.get(Category.parameter, "acronyms", use: getAcronyms)
    }
    
    func getAll(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Category> {
        return try req.content.decode(Category.self).save(on: req)
    }
    
    func get(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Category.self).flatMap(to: HTTPStatus.self) { acronym in
            return acronym.delete(on: req).transform(to: .noContent)
        }
    }
 
    func getAcronyms(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Category.self).flatMap(to: [Acronym].self, { category in
            return try category.acronyms.query(on: req).all()
        })
    }

}
