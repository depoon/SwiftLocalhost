//
//  LocalhostRouter.swift
//  UITests
//
//  Created by Kenneth Poon on 11/10/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation

public protocol LocalhostRouter {
    
    init(portNumber: UInt)
    func get(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?))
    func post(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?))
    func delete(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?))
    func put(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?))
    func patch(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?))
    func head(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?))
    func options(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?))
    
    func startListening()
    func stopListening()
}
