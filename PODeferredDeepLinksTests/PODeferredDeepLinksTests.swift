//
//  PODeferredDeepLinksTests.swift
//  PODeferredDeepLinksTests
//
//  Created by Mark Norman on 7/2/19.
//  Copyright © 2019 True Development LLC. All rights reserved.
//

import XCTest
@testable import PODeferredDeepLinks

class PODeferredDeepLinksTests: XCTestCase {

    var goodAPIKey: String!
    var badAPIKey: String!
    
    override func setUp() {
        super.setUp()
        
        goodAPIKey = "8e5e15546f0396f2751438cd797cd07a"
        badAPIKey = "12345"
    }

    override func tearDown() {
        goodAPIKey = nil
        badAPIKey = nil
        
        super.tearDown()
    }

    func testMissingAPIKey() {
        let promise = expectation(description: "Failure due to missing API key")
        
        DeepLinker.shared.testMode = true
        DeepLinker.shared.deviceIdentifier = "iPhone-iOS-12.1.4"
        DeepLinker.shared.ipAddress = "97.87.51.40"
        DeepLinker.shared.fetchDeepLinkData("") { (data) in
            if data.success == false,
            data.message == DeepLinker.MISSING_API_KEY_ERROR {
                promise.fulfill()
            } else {
                XCTFail("FAIL: Call returned success (\(data.success)) OR error message was incorrect (\(data.message ?? "no message"))")
            }
        }
        
        wait(for: [promise], timeout: 5)
    }
    
    func testInvalidAPIKey() {
        let prominse = expectation(description: "Failure due to invalid API key (401)")
        
        DeepLinker.shared.testMode = true
        DeepLinker.shared.deviceIdentifier = "iPhone-iOS-12.1.4"
        DeepLinker.shared.ipAddress = "97.87.51.40"
        DeepLinker.shared.fetchDeepLinkData(badAPIKey) { (data) in
            if data.success == false,
            data.message == DeepLinker.UNAUTHORIZED_ERROR {
                prominse.fulfill()
            } else {
                XCTFail("FAIL: Call returned success (\(data.success)) OR error message was incorrect (\(data.message ?? "no message"))")
            }
        }
        
        wait(for: [prominse], timeout: 5)
    }
    
    func testDeviceIdentifierNotFound() {
        let prominse = expectation(description: "Returns success: false and a message after not finding a matching device identifier")
        
        DeepLinker.shared.testMode = true
        DeepLinker.shared.deviceIdentifier = "iPhone-iOS-0.0.0"
        DeepLinker.shared.ipAddress = "1.1.1.1"
        DeepLinker.shared.fetchDeepLinkData(goodAPIKey) { (data) in
            if data.success == false,
            data.message != DeepLinker.UNAUTHORIZED_ERROR {
                prominse.fulfill()
            } else {
                XCTFail("FAIL: Call returned success when it should have failed")
            }
        }
        
        wait(for: [prominse], timeout: 10)
    }
    
    func testDeviceIdentifierFound() {
        let prominse = expectation(description: "Returns success: true and a payload containing the deep link for the matched device identifier")
        
        DeepLinker.shared.testMode = true
        DeepLinker.shared.deviceIdentifier = "iPhone-iOS-12.1.4"
        DeepLinker.shared.ipAddress = "97.87.51.40"
        DeepLinker.shared.fetchDeepLinkData(goodAPIKey) { (data) in
            if data.success,
            let payload = data.payload {
                print(payload)
                prominse.fulfill()
            } else {
                XCTFail("FAIL: Call was unsuccessful or was missing deep link (\(data.payload.debugDescription))")
            }
        }
        
        wait(for: [prominse], timeout: 5)
    }
}
