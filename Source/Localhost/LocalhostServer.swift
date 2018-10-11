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
    
    func get(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.get(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })
    }
    
    func post(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.post(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })
    }
    
    func delete(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.delete(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })

    }

    func put(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.put(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(routeBlock: routeBlock, crRequest: req, crResponse: res)
        })

    }

    func startListening(){
        self.server.startListening(nil, portNumber: self.portNumber)
    }
    
    func stopListening() {
        self.server.stopListening()
    }
}

class LocalhostServer {
    
    let server: CRHTTPServer
    let portNumber: UInt
    
    var recordedRequests: [URLRequest]
    
    required init(portNumber: UInt){
        server = CRHTTPServer()
        self.portNumber = portNumber
        recordedRequests = [URLRequest]()
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
        if let data = response.data {
            crResponse.bodyData = data
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
/*
     server.get("/collect") { (req, res, next) in
         //res.allHTTPHeaderFields = ["Content-Type": "image/gif"]
         let httpHeaders: [String: String] = [
             "Content-Type": "image/gif",
             "Date": "Tue, 25 Sep 2018 17:30:12 GMT",
             "Expires":"Mon, 01 Jan 1990 00:00:00 GMT",
             "Last-Modified": "Sun, 17 May 1998 03:00:00 GMT",
             "Pragma": "no-cache",
             "Server":"Golfe2",
             "X-Content-Type-Options": "nosniff"
         ]
         res.setStatusCode(200, description: nil)
         res.setAllHTTPHeaderFields(httpHeaders)
         let fileUrl = Bundle(for: type(of: self)).url(forResource: "responseCollect", withExtension: "gif")!
         //res.bodyData = try! Data(contentsOf: fileUrl)
         //res.send("Hello world!")
         res.send(try! Data(contentsOf: fileUrl))
    }
 */
