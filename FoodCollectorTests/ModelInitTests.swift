//
//  ModelInitTests.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/11/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import XCTest
import FoodCollector

class ModelInitTests: XCTestCase {

    let model = FCModel.sharedInstance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testModelInit() {
        // This is an example of a functional test case.
        XCTAssertNotNil(self.model ,"model is nill")
    }

    func testModelPublicationsMockServer() {
        // This is an example of a functional test case.
        XCTAssertNotNil(self.model.publications.count, "publications were not created")
    
    }
    

/*    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
*/
}
