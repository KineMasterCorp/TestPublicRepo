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
    var videoCache: VideoCache!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = HTTPLoader()
        sut.delegate = self
        videoCache = VideoCache()
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
    
    private var promiseDownload: XCTestExpectation!
    private var error: Error?
    
    func testCancelDownload() throws {
        let url = URL(string: "https://cdn-project-feed.kinemasters.com/projects/604df55701071402c972bb45/1qp3AeYWAbH9kn26SvRVMSWvBT2.mp4")!
        
        promiseDownload = expectation(description: "OK")

        // When
        sut.load(url: url)
        sut.load(url: url, offset: 10, length: 1000)
        sut.load(url: url, offset: 2000, length: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NSLog("Cancel request.")
            self.sut.cancelAllRequests()
        }
        
        // Then
        wait(for: [promiseDownload], timeout: 20)
        
        XCTAssert(error != nil)
    }

    func testDownload() throws {
        // Given
        print("start testDownload")
        let url = URL(string: "https://cdn-project-feed.kinemasters.com/projects/604df55701071402c972bb45/1qp3AeYWAbH9kn26SvRVMSWvBT2.mp4")!
        
        promiseDownload = expectation(description: "OK")

        // When
        sut.load(url: url)
        sut.load(url: url, offset: 10, length: 1000)
        sut.load(url: url, offset: 2000, length: nil)
        
        // Then
        wait(for: [promiseDownload], timeout: 60)
        
        let response = videoCache.getResponse(for: url)
        let data = videoCache.getData(for: url, offset: 0, length: nil)
        
        XCTAssert(response != nil, "response is nil!")
        XCTAssert(data != nil, "data is nil!")
        XCTAssert(response!.expectedContentLength == data!.count, "downloaded: \(data!.count), content-length: \(response!.expectedContentLength)")
    }

    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension HTTPLoaderTests: HTTPLoaderDelegate {
    func didRecvResponse(url: URL, response: URLResponse) {
        NSLog("didRecvResponse for \(url.lastPathComponent), response: \(response)")
        videoCache.prepare(for: url, with: response)
    }

    func didRecvData(url: URL, data: Data, offset: Int) {
        NSLog("didRecvData for \(url.lastPathComponent), offset: \(offset), count: \(data.count)")
        videoCache.storeData(for: url, data: data, offset: offset)
    }

    func didComplete(url: URL, error: Error?) {
        NSLog("didComplete for \(url.lastPathComponent), error: \(error?.localizedDescription ?? "none")")
        self.error = error
        promiseDownload.fulfill()
    }
}

