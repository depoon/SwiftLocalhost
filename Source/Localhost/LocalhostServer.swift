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
        let method: String = "GET"
        self.setOverlayingRoute(method: method, path: path, routeBlock: routeBlock)
        self.server.get(path, block: {  [weak self] (req, res, next) in
            guard let routeBlockPopped = self?.popOverlayingRoute(method: method, path: path) else {
                return
            }
            self?.handleRoute(httpMethod: method,
                              routeBlock: routeBlockPopped,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func post(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        let method: String = "POST"
        self.setOverlayingRoute(method: method, path: path, routeBlock: routeBlock)
        self.server.post(path, block: {  [weak self] (req, res, next) in
            guard let routeBlockPopped = self?.popOverlayingRoute(method: method, path: path) else {
                return
            }
            self?.handleRoute(httpMethod: method,
                              routeBlock: routeBlockPopped,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func delete(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        let method: String = "DELETE"
        self.setOverlayingRoute(method: method, path: path, routeBlock: routeBlock)
        self.server.delete(path, block: {  [weak self] (req, res, next) in
            guard let routeBlockPopped = self?.popOverlayingRoute(method: method, path: path) else {
                return
            }
            self?.handleRoute(httpMethod: method,
                              routeBlock: routeBlockPopped,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func put(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        let method: String = "PUT"
        self.setOverlayingRoute(method: method, path: path, routeBlock: routeBlock)
        self.server.put(path, block: {  [weak self] (req, res, next) in
            guard let routeBlockPopped = self?.popOverlayingRoute(method: method, path: path) else {
                return
            }
            self?.handleRoute(httpMethod: method,
                              routeBlock: routeBlockPopped,
                              crRequest: req,
                              crResponse: res)
        })
    }

    public func patch(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        let method: String = "PATCH"
        self.setOverlayingRoute(method: method, path: path, routeBlock: routeBlock)
        self.server.add(path, block: {  [weak self] (req, res, next) in
            guard let routeBlockPopped = self?.popOverlayingRoute(method: method, path: path) else {
                return
            }
            self?.handleRoute(httpMethod: method,
                              routeBlock: routeBlockPopped,
                              crRequest: req,
                              crResponse: res)
        })
    }

    public func head(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        let method: String = "HEAD"
        self.setOverlayingRoute(method: method, path: path, routeBlock: routeBlock)
        self.server.head(path, block: {  [weak self] (req, res, next) in
            guard let routeBlockPopped = self?.popOverlayingRoute(method: method, path: path) else {
                return
            }
            self?.handleRoute(httpMethod: method,
                              routeBlock: routeBlockPopped,
                              crRequest: req,
                              crResponse: res)
        })
    }
    
    public func options(_ path: String, routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        let method: String = "OPTIONS"
        self.setOverlayingRoute(method: method, path: path, routeBlock: routeBlock)
        self.server.options(path, block: {  [weak self] (req, res, next) in
            guard let routeBlockPopped = self?.popOverlayingRoute(method: method, path: path) else {
                return
            }
            self?.handleRoute(httpMethod: method,
                              routeBlock: routeBlockPopped,
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
    
    var overlayingRoutes: [LocalhostServerMethodPath: [LocalhostServerRoute]]
    
    public var recordedRequests: [URLRequest]
    
    public required init(portNumber: UInt){
        server = CRHTTPServer()
        self.portNumber = portNumber
        recordedRequests = [URLRequest]()
        overlayingRoutes = [LocalhostServerMethodPath: [LocalhostServerRoute]]()
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
        case .PATCH:
            self.patch(path, routeBlock: routeBlock)
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
    case GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
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

struct LocalhostServerMethodPath: Hashable, Equatable {
    let method: String
    let path: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(method)
        hasher.combine(path)
    }
    
    public static func ==(lhs: LocalhostServerMethodPath, rhs: LocalhostServerMethodPath) -> Bool {
        guard lhs.method == rhs.method else { return false }
        guard lhs.path == rhs.path else { return false }
        return true
    }
}

struct LocalhostServerRoute {
    let pathMethod: LocalhostServerMethodPath
    let routeBlock: ((URLRequest) -> LocalhostServerResponse?)
}

extension LocalhostServer {
    func setOverlayingRoute(method: String,
                            path: String,
                            routeBlock: @escaping ((URLRequest) -> LocalhostServerResponse?)) {
        
        let localhostServerMethodPath = LocalhostServerMethodPath(method: method, path: path)
        let newServerRoute = LocalhostServerRoute(pathMethod: localhostServerMethodPath, routeBlock: routeBlock)
        let methodPathKeys = Array(self.overlayingRoutes.keys)
        if methodPathKeys.contains(localhostServerMethodPath), var existingRoutes = self.overlayingRoutes[localhostServerMethodPath] {
            existingRoutes.append(newServerRoute)
            self.overlayingRoutes[localhostServerMethodPath] = existingRoutes
        } else {
            let routes: [LocalhostServerRoute] = [
                newServerRoute
            ]
            self.overlayingRoutes[localhostServerMethodPath] = routes
        }
    }
    
    func popOverlayingRoute(method: String, path: String) -> ((URLRequest) -> LocalhostServerResponse?)? {
        let localhostServerMethodPath = LocalhostServerMethodPath(method: method, path: path)
        let methodPathKeys = Array(self.overlayingRoutes.keys)
        guard methodPathKeys.contains(localhostServerMethodPath),
            var existingRoutes = self.overlayingRoutes[localhostServerMethodPath],
            existingRoutes.count > 0  else {
                return nil
        }
        if existingRoutes.count == 1 {
            return existingRoutes.first?.routeBlock
        }
        let firstItem = existingRoutes.removeFirst()
        self.overlayingRoutes[localhostServerMethodPath] = existingRoutes
        return firstItem.routeBlock
    }
}
