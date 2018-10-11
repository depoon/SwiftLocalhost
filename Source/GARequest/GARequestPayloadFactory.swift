//
//  GARequestPayloadFactory.swift
//  UITests
//
//  Created by Kenneth Poon on 8/10/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation

class GARequestPayloadFactory {
    func createEvent(query: [String: String]) -> GARequestPayload? {
        guard let category = query["ec"],
            let action = query["ea"],
            let label = query["el"],
            let zIdentifier = query["z"], let zIdenfitierUInt64 = UInt64(zIdentifier) else {
            return nil
        }
        return GARequestPayload.event(zIdentifier: zIdenfitierUInt64, category: category, action: action, label: label)
    }
    
    func createScreeenEvent(query: [String: String]) -> GARequestPayload? {
        guard let type = query["t"],
            type == "screenview",
            let screenName = query["cd"],
            let zIdentifier = query["z"], let zIdenfitierUInt64 = UInt64(zIdentifier) else {
                return nil
        }
        return GARequestPayload.screenView(zIdentifier: zIdenfitierUInt64, screenName: screenName)
    }
}
