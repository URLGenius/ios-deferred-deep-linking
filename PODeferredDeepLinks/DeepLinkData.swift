//
//  DeepLinkData.swift
//  PODeferredDeepLinks
//
//  Created by Mark Norman on 6/17/19.
//  Copyright © 2019 True Development LLC. All rights reserved.
//

import Foundation

public class DeepLinkData: NSObject {
    
    public var success: Bool
    public var message: String?
    public var payload: String?
    
    init(data: [String: Any]) {
        success = data["success"] as? Bool ?? false
        message = data["message"] as? String
        payload = data["payload"] as? String
    }
    
    init(failureMessage: String) {
        success = false
        message = failureMessage
        payload = nil
    }
    
    public func toString() -> String {
        return "[success: \(success)]; [message: \(message ?? "No message")]; [payload: \(payload ?? "No payload")]"
    }
}
