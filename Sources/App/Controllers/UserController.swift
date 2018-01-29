import Foundation

final class UserController {
  let drop: Droplet
  
  init(drop: Droplet) {
    self.drop = drop
  }
  
  func list(_ req: Request) throws -> ResponseRepresentable {
    let list = try User.all()
    return try drop.view.make("userview", ["userlist": list.makeNode(in: nil)])
  }
  
  func create(_ req: Request) throws -> ResponseRepresentable {
    guard let username = req.data["username"]?.string else {
      return Response(status: .badRequest)
    }
    
    let user = User(username: username)
    try user.save()
    return Response(redirect: "/user")
  }
  
  func getUpload(_ req: Request) throws -> ResponseRepresentable {
    let list = try User.all()
    return try drop.view.make("upload", ["userlist": list.makeNode(in: nil)])
  }
  
  func postUpload(_ req: Request) throws -> ResponseRepresentable {
    
    guard
      let userId = req.formData?["userId"]?.int,
      let user = try User.find(userId),
      let imageBytes = req.formData?["image"]?.bytes,
      let filename = req.formData?["image"]?.filename
    else {
        return "whoops - something went wrong"
    }
    
    /// path to directory for saving the image
    let baseDir = URL(fileURLWithPath: self.drop.config.workDir).appendingPathComponent("images")
    
    /// path to directory of user for saving the image
    let userDir = baseDir.appendingPathComponent(user.username)
    let fileManager = FileManager()
    
    /// check whether directory already exists
    if !fileManager.fileExists(atPath: userDir.path) {
      /// create directory
      try fileManager.createDirectory(at: userDir, withIntermediateDirectories: false, attributes: nil)
    }
    
    let userDirWithImage = userDir.appendingPathComponent(filename)
    
    /// write image to directory
    let data = Data(bytes: imageBytes)
    fileManager.createFile(atPath: userDirWithImage.path, contents: data, attributes: nil)
    
    /// save image filename used as profile picture
    user.profileImage = filename
    try user.save()
    
    return Response(redirect: "/user/" + user.username)
  }
  
  func getProfile(_ req: Request) throws -> ResponseRepresentable {
    
    guard
      let username = req.parameters["username"]?.string,
      let user = try User.makeQuery().filter("username", username).first()
    else {
        return "couldn't find user"
    }
    
    let hasImage = user.profileImage != nil
    return try self.drop.view.make("profile", ["hasImage": hasImage, "user": user.makeNode(in: nil)])
  }
  
  func getProfileImage(_ req: Request) throws -> ResponseRepresentable {
    
    guard
      let username = req.parameters["username"]?.string,
      let user = try User.makeQuery().filter("username", username).first(),
      let imageName = user.profileImage
    else {
        return "could'nt find user or user has no profile image"
    }
    
    let imagePath = self.drop.config.workDir + "/images/" + user.username + "/" + imageName
    return try Response(filePath: imagePath)
  }
}
