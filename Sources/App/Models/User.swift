import FluentSQLite
import Vapor

final class User: SQLiteModel {
    var id: Int?
    var username: String
    var profileImage: String?
    
    init(id: Int? = nil, username: String, profileImage: String? = nil) {
        self.id = id
        self.username = username
        self.profileImage = profileImage
    }
}
extension User: Content {}
extension User: Migration {}
