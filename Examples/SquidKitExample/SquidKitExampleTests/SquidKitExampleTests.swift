//
//  SquidKitExampleTests.swift
//  SquidKitExampleTests
//
//  Created by Mike Leavy on 8/21/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import XCTest
import SquidKit

class SquidKitExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCache() {
        let stringCache = Cache<NSString, NSString>()
        
        stringCache.insert("foo", key: "a")
        stringCache.insert("bar", key: "b")
        
        let a = stringCache.get("a")
        let b = stringCache.get("b")
        
        XCTAssertEqual(a, "foo", "key a is not \"foo\"")
        XCTAssertEqual(b, "bar", "key b is not \"bar\"")
        
        // test that all caches of type NSString, NSString are the same
        let anotherStringCache = Cache<NSString, NSString>()
        let anotherA = anotherStringCache["a"]
        XCTAssertEqual(anotherA, "foo", "key a is not \"foo\"")
        
        let numberCache = Cache<NSString, NSNumber>()
        numberCache.insert(12, key: "12")
        numberCache.insert(24, key: "24")
        
        var twelve = numberCache.get("12")
        
        XCTAssertEqual(12, twelve, "cache entry for \"12\" is not 12")
        numberCache.remove(forKey: "12")
        twelve = numberCache["12"]
        XCTAssertNil(twelve, "expected nil result for key \"12\"")
    }
    
}
