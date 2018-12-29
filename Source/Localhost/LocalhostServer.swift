//
//  LocalhostServer.swift
//  UITests
//
//  Created by Kenneth Poon on 8/9/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation
import Criollo

extension LocalhostServer: LocalhostRouter {
    
    public func get(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.get(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })
    }
    
    public func post(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.post(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })
    }
    
    public func delete(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.delete(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })

    }

    public func put(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.put(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })

    }

    public func startListening(){
        self.server.startListening(nil, portNumber: self.portNumber)
    }
    
    public func stopListening() {
        self.server.stopListening()
    }
}

public class LocalhostServer {
    
    public let portNumber: UInt
    let server: CRHTTPServer
    
    var recordedRequests: [URLRequest]
    
    public required init(portNumber: UInt){
        server = CRHTTPServer()
        self.portNumber = portNumber
        recordedRequests = [URLRequest]()
    }
    
    public static func initializeUsingRandomPortNumber() -> LocalhostServer{
        let availablePort: UInt = UInt(LocalhostPort.availablePortNumber())
        return LocalhostServer(portNumber: availablePort)
    }
    
    fileprivate func handleRoute(routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?),
                         crRequest: CRRequest,
                         crResponse: CRResponse) {
        var request = URLRequest(url: crRequest.url)
        request.allHTTPHeaderFields = crRequest.allHTTPHeaderFields
        if let body = crRequest.body as? Data {
            request.httpBody = body
        }
        self.recordedRequests.append(request)
        guard let response = routeBlock(request) else {
            crResponse.setStatusCode(200, description: nil)
            return
        }
        let httpUrlResponse = response.httpUrlResponse
        crResponse.setStatusCode(UInt(httpUrlResponse.statusCode), description: nil)
        if let allHeaderFields = httpUrlResponse.allHeaderFields as? [String: String] {
            crResponse.setAllHTTPHeaderFields(allHeaderFields)
        }
        if let data = response.data as? Data {
            if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                crResponse.send(dataString)
                return
            }
            crResponse.send(data)
        }
    }
}

public enum LocalhostRequestMethod {
    case get, post, put, delete, patch
}
public struct LocalhostRequest {
    
    let method: LocalhostRequestMethod
    let url: URL
    
    public init(method: LocalhostRequestMethod, url: URL) {
        self.method = method
        self.url = url
    }
    
}

protocol LocalhostResponse {
    var httpUrlResponse: HTTPURLResponse { get }
    var body: Data { get }
}

struct LocalhostJsonResponse: LocalhostResponse {
    var httpUrlResponse: HTTPURLResponse
    var body: Data
    
    init(httpUrlResponse: HTTPURLResponse, body: Data){
        self.httpUrlResponse = httpUrlResponse
        self.body = body
    }
    
    
}
