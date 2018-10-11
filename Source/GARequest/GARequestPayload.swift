//
//  GARequestPayload.swift
//  UITests
//
//  Created by Kenneth Poon on 8/10/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation

public enum GARequestPayload {
    case event(zIdentifier: UInt64?, category: String, action: String, label: String),
        screenView(zIdentifier: UInt64?, screenName: String)
    
    var zIdentifier: UInt64? {
        switch self {
        case .event(let identifier, _, _, _):
            return identifier
        case .screenView(let identifier, _):
            return identifier
        }
    }
}

extension GARequestPayload: Equatable {
    public static func ==(lhs: GARequestPayload, rhs: GARequestPayload) -> Bool {
        switch (lhs, rhs) {
        case (let .event(_, lCategory, lAction, lLabel), let .event(_, rCategory, rAction, rLabel)):
            return lCategory == rCategory &&
                lAction == rAction &&
                lLabel == rLabel
            
        case (let .screenView(_, lScreenName), let .screenView(_, rScreenName)):
            return lScreenName == rScreenName
        default:
            return false
        }
    }
}


