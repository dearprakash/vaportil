
import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acornymsRoute = router.grouped("api", "acronyms")
        acornymsRoute.get(use: getAll)
        acornymsRoute.post(Acronym.self, use: create)
        acornymsRoute.get(Acronym.parameter , use: get)
        acornymsRoute.delete(Acronym.parameter, use: delete)
        acornymsRoute.put(Acronym.parameter, use: update)
        acornymsRoute.get(Acronym.parameter, "user", use: getUser)
        acornymsRoute.get(Acronym.parameter, "categories", use: getCategories)
        acornymsRoute.post(Acronym.parameter, "categories", Category.parameter, use: addCategories)
        acornymsRoute.get("search", use: search)
    }
    
    func getAll(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func create(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    
    func get(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self).flatMap(to: HTTPStatus.self) { acronym in
                return acronym.delete(on: req).transform(to: .noContent)
        }
    }
    
    func update(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        }
    }
    
    func getUser(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
            return acronym.user.get(on: req)
        }
    }
    
    func getCategories(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self, { acronym in
            return try acronym.categories.query(on: req).all()
        })
    }
    
    func addCategories(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                       req.parameters.next(Acronym.self),
                       req.parameters.next(Category.self)) { acronym, category in
                        
                        let pivot = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
                        return pivot.save(on: req).transform(to: .ok)
                        
        }
    }
    
    func search(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
}
