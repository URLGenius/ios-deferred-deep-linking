//
//  Log.swift
//  PODeferredDeepLinks
//
//  Created by Mark Norman on 6/17/19.
//  Copyright © 2019 True Development LLC. All rights reserved.
//

import Foundation

internal class Log: NSObject {
    
    internal static func log(_ system: String, _ message: String) {
        print("\(system) :: \(message)")
    }
}

internal func print(_ items: Any...) {
    var newItems = [String]()
    newItems.append("PO")
    
    var index = items.startIndex
    let endIndex = items.endIndex
    
    repeat {
        newItems.append("\(items[index])")
        index += 1
    }
    while index < endIndex
    
    Swift.print(newItems.joined(separator: " :: "), separator: " ", terminator: "\n")
}
