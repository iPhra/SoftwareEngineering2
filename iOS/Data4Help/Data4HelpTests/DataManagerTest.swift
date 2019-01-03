//
//  DataManagerTest.swift
//  Data4HelpTests
//
//  Created by Virginia Negri on 03/01/2019.
//  Copyright © 2019 Lorenzo Molteni Negri. All rights reserved.
//

import XCTest
import HealthKit
@testable import Data4Help

class DataManagerTest: XCTestCase {
    
    let biologicalSexEnum : [String] = ["F", "M", "U", ""]
    let dataManager: DataManager = DataManager()
    var sample: HKSample?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.sample = HKQuantitySample(type: HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!, quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: 100), start: Date(timeIntervalSince1970: TimeInterval(0)), end: Date(timeIntervalSince1970: TimeInterval(0)))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBiologicalSex() {
        let sex: String = self.dataManager.getBiologicalSex()
        XCTAssert(biologicalSexEnum.contains(sex))
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testTimestamp(){
        XCTAssertEqual(self.dataManager.getTimestamp(sample: (self.sample)!), "1970-01-01 00:00:00")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
