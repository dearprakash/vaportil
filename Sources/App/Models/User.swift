
import FluentMySQL
import Vapor
import Foundation

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String

    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}


extension User: MySQLUUIDModel {}
extension User: Content { }
extension User: Migration { }
extension User: Parameter { }

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }    
}
