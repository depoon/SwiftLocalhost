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
            self?.handleRoute(httpMethod: "GET",
                              routeBlock: routeBlock,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func post(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.post(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(httpMethod: "POST",
                              routeBlock: routeBlock,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func delete(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.delete(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(httpMethod: "DELETE",
                              routeBlock: routeBlock,
                              crRequest: req,
                              crResponse: res)
        })
    }

    public func put(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.put(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(httpMethod: "PUT",
                              routeBlock: routeBlock,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func head(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.head(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(httpMethod: "HEAD",
                              routeBlock: routeBlock,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func options(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        self.server.options(path, block: {  [weak self] (req, res, next) in
            self?.handleRoute(httpMethod: "OPTIONS",
                              routeBlock: routeBlock,
                              crRequest: req,
                              crResponse: res)
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
    
    public var recordedRequests: [URLRequest]
    
    public required init(portNumber: UInt){
        server = CRHTTPServer()
        self.portNumber = portNumber
        recordedRequests = [URLRequest]()
    }
    
    public static func initializeUsingRandomPortNumber() -> LocalhostServer{
        let availablePort: UInt = UInt(LocalhostPort.availablePortNumber())
        return LocalhostServer(portNumber: availablePort)
    }
    
    fileprivate func handleRoute(httpMethod: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?),
                         crRequest: CRRequest,
                         crResponse: CRResponse) {
        var request = URLRequest(url: crRequest.url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = crRequest.allHTTPHeaderFields
        if let body = crRequest.bodyFromData() {
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
    
    public func route(method: LocalhostRequestMethod,
               path: String,
               responseData: Data,
               statusCode: Int = 200,
               responseHeaderFields: [String: String]? = nil) {
        let routeBlock = self.routeBlock(path: path,
                                         responseData: responseData,
                                         statusCode: statusCode,
                                         responseHeaderFields: responseHeaderFields)
        switch method {
        case .GET:
            self.get(path, routeBlock: routeBlock)
        case .POST:
            self.post(path, routeBlock: routeBlock)
        case .PUT:
            self.put(path, routeBlock: routeBlock)
        case .DELETE:
            self.delete(path, routeBlock: routeBlock)
        case .HEAD:
            self.head(path, routeBlock: routeBlock)
        case .OPTIONS:
            self.options(path, routeBlock: routeBlock)
        }
    }
    
    fileprivate func routeBlock(path: String,
                                responseData: Data,
                                statusCode: Int = 200,
                                responseHeaderFields: [String: String]? = nil) -> ((URLRequest) -> LocalhostServerResponse?) {
        let block: ((URLRequest) -> LocalhostServerResponse?) = { _ in
            let serverPort = self.portNumber
            let requestURL: URL = URL(string: "http://localhost:\(serverPort)\(path)")!
            let httpUrlResponse = HTTPURLResponse(url: requestURL,
                                                  statusCode: statusCode,
                                                  httpVersion: nil,
                                                  headerFields: responseHeaderFields)!
            return LocalhostServerResponse(httpUrlResponse: httpUrlResponse, data: responseData)
        }
        return block
    }
}

public enum LocalhostRequestMethod {
    case GET, POST, PUT, DELETE, HEAD, OPTIONS
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

extension CRRequest {
    func bodyFromData() -> Data? {
        guard let aBody = self.body else {
            return nil
        }
        if let jsonObject = try? JSONSerialization.data(withJSONObject: aBody, options: self.jsonWriteOptions()) {
            return jsonObject
        }
        if let bodyData = aBody as? Data {
            return bodyData
        }
        return nil
    }
    
    fileprivate func jsonWriteOptions() -> JSONSerialization.WritingOptions {
        if #available(iOS 11.0, *) {
            return [.sortedKeys, .prettyPrinted]
        }
        return .prettyPrinted
    }
}

