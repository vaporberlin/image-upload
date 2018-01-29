import Vapor
import FluentProvider

final class User: Model {
  var storage = Storage()
  var username: String
  var profileImage: String?
  
  init(username: String, profileImage: String? = nil) {
    self.username = username
    self.profileImage = profileImage
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("username", username)
    try row.set("profileImage", profileImage)
    return row
  }
  
  init(row: Row) throws {
    self.username = try row.get("username")
    self.profileImage = try row.get("profileImage")
  }
}

// MARK: Fluent Preparation

extension User: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string("username")
      builder.string("profileImage", optional: true)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

// MARK: Node

extension User: NodeRepresentable {
  func makeNode(in context: Context?) throws -> Node {
    var node = Node(context)
    try node.set("id", id)
    try node.set("username", username)
    try node.set("profileImage", profileImage)
    return node
  }
}
