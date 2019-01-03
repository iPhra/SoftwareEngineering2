//
//  StorageManagerTest.swift
//  Data4HelpTests
//
//  Created by Virginia Negri on 03/01/2019.
//  Copyright © 2019 Lorenzo Molteni Negri. All rights reserved.
//

import XCTest
import CoreData
@testable import Data4Help

class StorageManagerTest: XCTestCase {
    
    var storageManager: StorageManager?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.storageManager = StorageManager()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        storageManager?.setAutomatedSOSValue(value: false)
    }

    func testAutomatedSOS() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        storageManager?.initAutomatedSOS()
        XCTAssert((storageManager?.getAllData(ofEntity: "AutomatedSOS").count)==1)
        XCTAssertEqual(storageManager?.getAutomatedSOS(), false)
        storageManager?.setAutomatedSOSValue(value: true)
        XCTAssertEqual(storageManager?.getAutomatedSOS(), true)        
    }
    
    func testInvalidDataTypes() {
        let objects: [NSManagedObject] = (storageManager?.getAllDataObjects(ofType: "InvalidType"))!
        XCTAssert(objects.count==0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
