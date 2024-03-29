import Vapor
import FluentMySQL
import Foundation

final class AcronymCategoryPivot: MySQLUUIDPivot {
    typealias Left = Acronym
    typealias Right = Category
    
    var id: UUID?
    
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    static var leftIDKey: LeftIDKey = \AcronymCategoryPivot.acronymID
    static var rightIDKey: RightIDKey = \AcronymCategoryPivot.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}


extension AcronymCategoryPivot : Migration { }
