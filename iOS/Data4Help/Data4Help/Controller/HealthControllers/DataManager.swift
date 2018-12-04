//
//  AutomatedSOSManager.swift
//  Data4Help
//
//  Created by Virginia Negri on 27/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import HealthKit



/*
 * Handles health data access thorugh HKHealthStore object
 */
class DataManager: NSObject {
    
    //MARK: Properties
    
    let healthStore:HKHealthStore = HKHealthStore()
    
    //MARK: Singleton Instance
    
    class var sharedInstance: DataManager {
        struct Singleton {
            static let instance = DataManager()
        }
        return Singleton.instance
    }
    
    
    //MARK: functions
    func authorizeHKinApp(){
        
        // Health data to read
        let hkTypesToRead:Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
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
    }
    
    public func enableAutomatedSOS(){
        //
    }
    
    
    public func enableBackgroundData(){
        
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        self.healthStore.enableBackgroundDelivery(for: sampleType!, frequency: .immediate) { (success, error) in
            if let unwrappedError = error {
                print("could not enable background delivery: \(unwrappedError)")
            }
            if success {
                print("background delivery enabled")
            }
        }
        //2.  open observer query
        let query = HKObserverQuery(sampleType: sampleType!, predicate: nil) { (query, completionHandler, error) in
            
            self.updateHeartRates() {
                completionHandler()
            }
            
            
        }
        healthStore.execute(query)

    }
    func updateHeartRates(completionHandler: @escaping () -> Void) {
        
        var anchor: HKQueryAnchor?
        
        let sampleType =  HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        let anchoredQuery = HKAnchoredObjectQuery(type: sampleType!, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit) { [unowned self] query, newSamples, deletedSamples, newAnchor, error in
            
            self.handleNewSamples(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!)
            
            anchor = newAnchor
            
            completionHandler()
        }
        healthStore.execute(anchoredQuery)
    }
    
    func handleNewSamples(new: [HKQuantitySample], deleted: [HKDeletedObject]) {
        print("last sample = \(String(describing: new.last!.quantity))")
        /*
        for sample in new{
            print("new sample added = \(sample.quantity)")
        }*/
    }
}
