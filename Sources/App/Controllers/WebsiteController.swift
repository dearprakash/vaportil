import Leaf
import Vapor

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: index)
        router.get("acronyms", Acronym.parameter, use: acronym)
        router.get("users", User.parameter, use: user)
        router.get("allusers", use: allUsers)
        router.get("categories", use: categories)
        router.get("category", Category.parameter, use: category)
        router.get("acronyms", "create", use: createAcronym)
        router.post(Acronym.self, at: "acronyms", "create", use: createAcronymPost)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let context = IndexContext(title: "Spider-man", acronyms: acronyms)
            return try req.view().render("index", context)
        }
    }
    
    func acronym(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            return acronym.user.get(on: req).flatMap(to: View.self) { user in
                let context = try AcronymContext(title: acronym.long, acronym: acronym, user: user, categories: acronym.categories.query(on: req).all())
                return try req.view().render("acronym", context)
            }
        }
        
    }
    
    func user(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            let context = try UserContext(title: user.name, user: user, acronyms: user.acronyms.query(on: req).all())
            return try req.view().render("user", context)
        }
    }

    func allUsers(_ req: Request) throws -> Future<View> {
//      Option 1
//        return User.query(on: req).all().flatMap(to: View.self) { allUsers in
//            let context = AllUsersContext(title: "Users", users: allUsers)
//            return try req.view().render("users", context)
//        }
        let context = AllUsersContext(title: "All Users", users: User.query(on: req).all())
        return try req.view().render("users", context)
        
    }
    
    func categories(_ req: Request) throws -> Future<View> {
        return Category.query(on: req).all().flatMap(to: View.self) { allCategories in
            let context = CategoriesContext(title: "Categories", categories: allCategories)
            return try req.view().render("categories", context)
        }
    }
    
    func category(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self).flatMap(to: View.self) { category in
            let context = try CategoryContext(name: category.name, acronyms: category.acronyms.query(on: req).all())
            return try req.view().render("category", context)
        }
    }

    
    func createAcronym(_ req: Request) throws -> Future<View> {
        let context = CreateAcronymContext(users: User.query(on: req).all())
        return try req.view().render("createAcronym", context)
    }
    
    func createAcronymPost(_ req: Request, acronym: Acronym) throws -> Future<Response> {
        return acronym.save(on: req).map(to: Response.self, { acronym in
            guard let id = acronym.id else {
                return req.redirect(to: "/")
            }
            return req.redirect(to: "/acronyms/\(id)")
        })
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]
}


struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
    let categories: Future<[Category]>
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: Future<[Acronym]>
}

struct AllUsersContext: Encodable {
    let title: String
    let users: Future<[User]>
}

struct CategoriesContext: Encodable {
    let title: String
    let categories: [Category]
}

struct CategoryContext: Encodable {
    let name: String
    let acronyms: Future<[Acronym]>
}


struct CreateAcronymContext: Encodable {
    let title = "Create an Acronym"
    let users: Future<[User]>
}
