//
//  Utility.swift
//  PODeferredDeepLinks
//
//  Created by Mark Norman on 6/17/19.
//  Copyright © 2019 True Development LLC. All rights reserved.
//

import Foundation

internal class Utility: NSObject {
    
    internal static func getIPAddress(for network: Network) -> String? {
        var address: String?
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        guard let firstAddr = ifaddr else {
            return nil
        }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    internal enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
    }
    
    internal class func getAppVersion() -> String {
        let info = Bundle.main.infoDictionary
        if let version = info?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
    
    internal class func getAppBuildNumber() -> String {
        let info = Bundle.main.infoDictionary
        if let build = info?["CFBundleVersion"] as? String {
            return build
        }
        return ""
    }
}
