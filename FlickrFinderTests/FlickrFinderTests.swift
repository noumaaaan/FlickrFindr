//
//  FlickrFinderTests.swift
//  FlickrFinderTests
//
//  Created by Nouman Mehmood on 13/02/2021.
//

import XCTest
@testable import FlickrFinder

class FlickrFinderTests: XCTestCase {

    let main = ViewController()
    
    // Check JSON returns not nill
    func testNilJSONData(){
        let result: () = main.getResponse(tags: "car", pageParam: 1)
        XCTAssertNotNil(result)
    }
    
    // Check JSON returns nill
    func testJSONData(){
        let result: () = main.getResponse(tags: "aadwdwfwefwfwfwfwff", pageParam: 1)
        XCTAssertNil(result)
    }
}
