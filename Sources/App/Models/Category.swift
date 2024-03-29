
import FluentMySQL
import Vapor

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
}


extension Category: MySQLModel { }
extension Category: Content { }
extension Category: Parameter { }
extension Category: Migration { }

extension Category {
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
        return siblings()
    }
}
