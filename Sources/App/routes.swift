import Vapor

public func routes(_ router: Router) throws {
    /* User */
    let userController = UserController()
    router.get("user", use: userController.list)
    router.post("user", use: userController.create)
    router.get("upload", use: userController.getUpload)
    router.post("upload", use: userController.postUpload)
    router.get("user", ":username", use: userController.getProfile)
    router.get("profile-image", ":username", use: userController.getProfileImage)
}
