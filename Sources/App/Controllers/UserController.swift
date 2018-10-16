import Foundation

final class UserController {
    // view with users
    func list(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap { users in
            let data = ["userlist": users]
            return try req.view().render("userview", data)
        }
    }
    
    // create a new user
    func create(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(User.self).flatMap { user in
            return user.save(on: req).map { _ in
                return req.redirect(to: "users")
            }
        }
    }
}

func getUpload(_ req: Request) throws -> Future<View> {
    return User.query(on: req).all().flatMap { users in
        let data = ["userlist": users]
        return try req.view().render("upload", data)
    }
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
    return try self.req.view().render("profile", ["hasImage": hasImage, "user": user.makeNode(in: nil)])
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
