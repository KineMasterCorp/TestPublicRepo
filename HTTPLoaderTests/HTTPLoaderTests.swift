//
//  HTTPLoaderTests.swift
//  HTTPLoaderTests
//
//  Created by JT3 on 2021/06/22.
//

import XCTest

@testable import FeedUI

class HTTPLoaderTests: XCTestCase {
    var sut: HTTPLoader!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = HTTPLoader()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDownload() throws {
        // Given
        print("start testDownload")
        let url = URL(string: "https://cdn-project-feed.kinemasters.com/projects/604df55701071402c972bb45/1qp3AeYWAbH9kn26SvRVMSWvBT2.mp4")!
        let promise = expectation(description: "OK")
        
        let range = HTTPRange(offset: 0, length: 512000)
        
        // When
        sut.load(url: url, range: range) { data, complete in
            promise.fulfill()
            print("testDownload: data: \(data.count), complete: \(complete)")
        }
        
        // Then
        wait(for: [promise], timeout: 10)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
