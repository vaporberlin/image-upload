import Vapor

extension Droplet {
  func setupRoutes() throws {
    
    let userController = UserController(drop: self)
    get("user", handler: userController.list)
    post("user", handler: userController.create)
    get("upload", handler: userController.getUpload)
    post("upload", handler: userController.postUpload)
    get("user", ":username", handler: userController.getProfile)
    get("profile-image", ":username", handler: userController.getProfileImage)
  }
}
