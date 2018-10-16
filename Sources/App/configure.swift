//
//  configure.swift
//  App
//
//  Created by Akarsh Seggemu on 15.10.18.
//

import FluentSQLite
import Vapor

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    let myService = try EngineServerConfig.detect(port: 8001)
    services.register(myService)
}
