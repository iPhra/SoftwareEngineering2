//
//  AutomatedSOSManager.swift
//  Data4Help
//
//  Created by Virginia Negri on 27/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import HealthKit

let healthStore:HKHealthStore = HKHealthStore()

/*
 * Handles health data access thorugh HKHealthStore object
 */
class DataManager: NSObject {
    
    

    //MARK: functions
    
    func authorizeHKinApp(){
        
        
        // Health data to read
        let hkTypesToRead:Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        ]
        
        
        if !HKHealthStore.isHealthDataAvailable(){
            print("No available health data")
            return
        }
        
        //request user authorization
        healthStore.requestAuthorization(toShare: nil, read: hkTypesToRead)
        {
            (success,error) -> Void in
            print("Read Write Authorization succeded")
            
            
        }
    }
    
    
    
    
    func getHeartRates()
    {
        //print("Debug print")
        let tHeartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let tHeartRateQuery = HKSampleQuery(sampleType: tHeartRate!, predicate:.none, limit: 0, sortDescriptors: nil) { query, results, error in
            
            if (results?.count)! > 0
            {
                var string:String = ""
                for result in results as! [HKQuantitySample]
                {
                    let HeartRate = result.quantity
                    string = "\(HeartRate)"
                    
                    let delimiter = "c" //remove "count/min"
                    var token = string.components(separatedBy: delimiter)
                    print (token[0]) //print only heart rate
                    //print(string)
                }
            }
        }
        
        healthStore.execute(tHeartRateQuery)
        
        /*
        healthStore.enableBackgroundDeliveryForType(sampleType, frequency: .Hourly, withCompletion: {(succeeded: Bool, error: NSError!) in
            
            if succeeded{
                println("Enabled background delivery of sampleType data changes")
            } else {
                if let theError = error{
                    print("Failed to enable background delivery of sampleType data changes. ")
                    println("Error = \(theError)")
                }
            }
        })*/
    }    
    
}
