//
//  LocalhostServerResponse.swift
//  UITests
//
//  Created by Kenneth Poon on 11/10/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation

public struct LocalhostServerResponse {
    public let httpUrlResponse: HTTPURLResponse
    public let data: Any?
    
    public init(httpUrlResponse: HTTPURLResponse, data: Any? = nil) {
        self.httpUrlResponse = httpUrlResponse
        self.data = data
    }
}
