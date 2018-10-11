//
//  GARequestLoggingServer.swift
//  UITests
//
//  Created by Kenneth Poon on 25/9/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation

public class GARequestLoggingServer {
    
    public let localhostServer: LocalhostServer
    
    var recordedEvents: [UInt64: GARequestPayload]
    
    public init(portNumber: UInt) {
        self.localhostServer = LocalhostServer(portNumber: portNumber)
        recordedEvents = [UInt64: GARequestPayload]()
    }
    
    public func startListening() {
        localhostServer.get("/collect") { request in
            guard let query = request.url?.query else {
                return nil
            }
            let splitQuery: [String] = query.components(separatedBy: "&")
            var queryDictionary = [String: String]()
            for subParameter in splitQuery {
                let items: [String] = subParameter.components(separatedBy: "=")
                queryDictionary[items[0]] = items[1]
            }
            
            if let event = GARequestPayloadFactory().createEvent(query: queryDictionary), let zIdentifier = event.zIdentifier {
                self.recordedEvents[zIdentifier] = event
            }
            if let screenEvent = GARequestPayloadFactory().createScreeenEvent(query: queryDictionary), let zIdentifier = screenEvent.zIdentifier  {
                self.recordedEvents[zIdentifier] = screenEvent
            }
            return nil
        }
        localhostServer.post("/batch") { request in
            return nil
        }
        self.localhostServer.startListening()
    }
    
    public func stopListening() {
        self.localhostServer.stopListening()
    }
    
    public func eventsReport() -> GARequestLoggingReport {
        
        let sortedKeys: [UInt64] = Array(self.recordedEvents.keys).sorted {
            return $0 < $1
        }
        var payloads = [GARequestPayload]()
        for key in sortedKeys {
            guard let payload = self.recordedEvents[key] else {
                continue
            }
            payloads.append(payload)
        }
        
        return GARequestLoggingReport(payloads: payloads)
    }
}
