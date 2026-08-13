//
//  DEPNotifyTests.swift
//  DEPNotifyTests
//
//  Created by Joel Rennich on 2/16/17.
//  Copyright © 2017 Orchard & Grove Inc.. All rights reserved.
//

import XCTest
@testable import DEPNotify

class DEPNotifyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStripMunkiTimestampMunki7() {
        // Munki 7 format: milliseconds + colon timezone, no space before tz.
        let tp = TrackProgress()
        let line = "2026-08-12 07:22:31.771-07:00     Downloading GoogleChrome-1.5.pkg..."
        XCTAssertEqual(tp.stripMunkiTimestamp(line), "Downloading GoogleChrome-1.5.pkg...")
    }

    func testStripMunkiTimestampLegacy() {
        // Pre-7 format: month-name date, space before tz.
        let tp = TrackProgress()
        let line = "Aug 13 2026 02:11:46 -0700     Installing Foo"
        XCTAssertEqual(tp.stripMunkiTimestamp(line), "Installing Foo")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
