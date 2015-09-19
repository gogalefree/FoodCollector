//
//  PublicationInitTests.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/11/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import XCTest
import FoodCollector


class PublicationInitTests: XCTestCase {

    var model = FCModel.sharedInstance as FCModel
    var publication : FCPublication!
    var publication1 : FCPublication!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        publication = model.publications[0]
        publication1 = model.publications[1]

    }
    
    override func tearDown() {
        publication = nil
        publication1 = nil
        super.tearDown()
    }

    func testuniqueId() {
        print("uniqu id ******** \(publication.uniqueId)")
        XCTAssertNotNil(publication.uniqueId, "unique id is nill")
    }

    
    func testAddress() {
        print("Address ******** \(publication.address)")
        XCTAssertNotNil(publication.address, "address is nill")
    }
   
    func testStartingDate() {
        print("Starting date ******** \(publication.startingDate.description)")
        XCTAssertNotNil(publication.startingDate, "strating date is nill")
    }
    
    func testEndingDate() {
        print("Ending date ******** \(publication.endingDate.description)")
        XCTAssertNotNil(publication.endingDate, "strating date is nill")
    }
    
    func testTypeOfCollecting() {
        print("Type Of Collecting date ******** \(publication.typeOfCollecting.rawValue)")
        XCTAssertNotNil(publication.typeOfCollecting.rawValue, "type of collecting date is nill")
    }
    
    func testcontactInfoExist() {
        print("Contact Information ******** \(publication.contactInfo)")
        XCTAssertNotNil(publication.contactInfo, "contact info is nill")
    }
    
    func testcontactInfoNotExist() {
        print("Contact Information ******** \(publication1.contactInfo)")
        XCTAssertNil(publication1.contactInfo, "contact info should be nill")
    }
    
    
}
