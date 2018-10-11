//
//  GARequestLoggingReport.swift
//  UITests
//
//  Created by Kenneth Poon on 10/10/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation

struct GARequestLoggingReport {
    let payloads: [GARequestPayload]
}

extension GARequestLoggingReport: Equatable {
    static func ==(lhs: GARequestLoggingReport, rhs: GARequestLoggingReport) -> Bool {
        guard lhs.payloads == rhs.payloads else {
            return false
        }
        return true
    }
}
