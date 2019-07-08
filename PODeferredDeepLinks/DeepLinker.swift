//
//  DeepLinker.swift
//  PODeferredDeepLinks
//
//  Created by Mark Norman on 6/17/19.
//  Copyright © 2019 True Development LLC. All rights reserved.
//

import Foundation

public class DeepLinker: NSObject {
    
    internal static let GENERIC_ERROR_MESSAGE = "An error occurred. Please try again later."
    internal static let MISSING_API_KEY_ERROR = "API key not set."
    internal static let UNAUTHORIZED_ERROR = "You are not authorized to access this endpoint."
    internal static let TIMEOUT_ERROR = "It appears you have poor network signal. Please try again later."
    
    internal var testMode = false
    private var _deviceIdentifier: String?
    internal var deviceIdentifier: String? {
        get {
            if testMode {
                return _deviceIdentifier
            }
            
            let device = UIDevice.current.model
            let osName = UIDevice.current.systemName
            let osVersion = UIDevice.current.systemVersion
            return "\(device)-\(osName)-\(osVersion)"
        }
        set(deviceId) {
            _deviceIdentifier = deviceId
        }
    }
    private var _ipAddress: String?
    internal var ipAddress: String? {
        get {
            if testMode {
                return _ipAddress
            }
            
            return Utility.getIPAddress(for: .wifi) ?? Utility.getIPAddress(for: .cellular)
        }
        set(ip) {
            _ipAddress = ip
        }
    }
    
    private override init() {}
    public static let shared = DeepLinker()
    
    public func fetchDeepLinkData(_ apiKey: String, _ callback: @escaping (_ deepLinkData: DeepLinkData) -> Void) {
        // TODO: remove when live api url is available
        //if !testMode {
        //    callback(DeepLinkData(failureMessage: "This framework is not yet setup to run in a live environment."))
        //    return
        //}
        
        guard apiKey != "" else {
            callback(DeepLinkData(failureMessage: DeepLinker.MISSING_API_KEY_ERROR))
            return
        }
        
        let params = [
            "api_key": apiKey,
            "ip_address": ipAddress,
            "device_type": deviceIdentifier
        ]
        let encodedData = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        // TODO: need live api url
        var apiUrl = "https://apistaging.urlgeni.us/api/v1/deep_links"
        if testMode {
            apiUrl = "https://apistaging.urlgeni.us/api/v1/deep_links"
        }
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Apple/iOS", forHTTPHeaderField: "X-PO-Device-Platform")
        request.setValue(Utility.getAppVersion(), forHTTPHeaderField: "X-PO-App-Version")
        request.setValue(Utility.getAppBuildNumber(), forHTTPHeaderField: "X-PO-App-Build-Number")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                callback(DeepLinkData(failureMessage: DeepLinker.GENERIC_ERROR_MESSAGE))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                callback(DeepLinkData(failureMessage: DeepLinker.GENERIC_ERROR_MESSAGE))
                return
            }
            
            switch response.statusCode {
            case 401:
                callback(DeepLinkData(failureMessage: DeepLinker.UNAUTHORIZED_ERROR))
                return
            case 408, 504:
                callback(DeepLinkData(failureMessage: DeepLinker.TIMEOUT_ERROR))
                return
            case 500:
                callback(DeepLinkData(failureMessage: DeepLinker.GENERIC_ERROR_MESSAGE))
                return
            default:
                break
            }
            
            if let data = data,
            let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                callback(DeepLinkData(data: responseData))
            } else {
                callback(DeepLinkData(failureMessage: DeepLinker.GENERIC_ERROR_MESSAGE))
            }
        }
        task.resume()
    }
}
