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
    
    // MARK: Properties
    var firstUpload = true
    
    var AutomatedSOSON = false
    
    let healthStore:HKHealthStore = HKHealthStore()
    
    // MARK: Singleton Instance
    
    class var sharedInstance: DataManager {
        struct Singleton {
            static let instance = DataManager()
        }
        return Singleton.instance
    }
    
    
    // MARK: Authorization requests
    
    func authorizeHKinApp(){
        
        // Health data to read
        let hkTypesToRead:Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!
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
    
    // Mark: functions
    
    public func toggleAutomatedSOS(){
        if(AutomatedSOSON){
            AutomatedSOSON = false;
        }
        else{
            AutomatedSOSON = true;
        }
        StorageManager.sharedInstance.setAutomatedSOSValue(value: AutomatedSOSON)
    }
    
    public func sampleTypesToRead() -> [HKSampleType] {
        var sampleTypes = [HKSampleType]()
        sampleTypes.append(HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
        //sampleTypes.append(HKSampleType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex))
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!)
        sampleTypes.append(HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!)
        
        return sampleTypes
    }
    
    // Mark: Background activities
    
    public func storeBiologicalSex(){
        do{
            let biologicalSex = try self.healthStore.biologicalSex().biologicalSex.rawValue
            var sex: String = ""
            switch biologicalSex {
            case 1:
                sex = "F"
            case 2:
                sex = "M"
            case 3:
                sex = "U"
            default:
                break
            }
            StorageManager.sharedInstance.storeBiologicalSex(biologicalSex: sex)
        }
        catch{
            print("Could not retrieve biological sex")
        }        
    }
    
    public func enableBackgroundData(input: HKSampleType, datatype: dataType){
        
        let sampleType = input
        
        self.healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (success, error) in
            if let unwrappedError = error {
                print("could not enable background delivery: \(unwrappedError)")
            }
            if success {
                print("background delivery enabled")
            }
        }
        //2.  open observer query
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, error) in
            
            self.updateHealthData(sampleType: input, datatype: datatype) {
                completionHandler()
            }
            
        }
        healthStore.execute(query)
        
    }


    
    func updateHealthData(sampleType: HKSampleType, datatype: dataType, completionHandler: @escaping () -> Void) {
        
        var anchor: HKQueryAnchor?
        
        let anchoredQuery = HKAnchoredObjectQuery(type: sampleType, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit) { [unowned self] query, newSamples, deletedSamples, newAnchor, error in
            
            switch(datatype.rawValue){
            case(dataType.heartrate.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!, dataType: datatype, unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
            case(dataType.sleepingHours.rawValue):
                self.handleSleepingHours(new: newSamples! as! [HKCategorySample], deleted: deletedSamples!)
            case(dataType.standingHours.rawValue):
                self.handleStandingHours(new: newSamples! as! [HKCategorySample], deleted: deletedSamples!)
            case(dataType.distanceWalkingRunning.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!, dataType: datatype,unit: HKUnit.mile())
            case(dataType.activeEnergy.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!,dataType: datatype, unit: HKUnit.kilocalorie())
            case(dataType.steps.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!,dataType: datatype, unit: HKUnit.count())
            case(dataType.weight.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!, dataType: datatype,unit: HKUnit.pound())
            case(dataType.height.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!, dataType: datatype,unit: HKUnit.foot())
            default:
                break
            }
            
            anchor = newAnchor
            
            completionHandler()
        }
        healthStore.execute(anchoredQuery)
    }

    func handleSleepingHours(new: [HKCategorySample], deleted:[HKDeletedObject]) {
        
        let sample = new.last!
        let sleepType = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
        let timestamp = getTimestamp(sample: sample)
        let sleptHours: Double = (sample.endDate.timeIntervalSince(sample.startDate))/3600
        print(sleptHours)
        
        print (timestamp) //print date-time
        print("hours \(sleepType) = \(sleptHours)")
        
        if(firstUpload){
            StorageManager.sharedInstance.deleteAllData(entityName: "Data")
            for s in new {
                StorageManager.sharedInstance.addData(entityName: "Data", type: dataType.sleepingHours.rawValue, timestamp: getTimestamp(sample: s), value: sleptHours)
            }
            firstUpload = false
        }
        else{
            StorageManager.sharedInstance.addData(entityName: "Data", type: dataType.sleepingHours.rawValue, timestamp: timestamp, value: sleptHours)
        }
    
    }
    
    func handleStandingHours(new: [HKCategorySample], deleted:[HKDeletedObject]) {
        //
    }
    
    func getTimestamp(sample: HKSample)-> String{
        let delimiter = "+" //remove "count/min"
        var token = sample.endDate.description.components(separatedBy: delimiter)
        var timestamp = token[0]
        _ = timestamp.popLast()
        return timestamp
    }
    
    
    func handleQuantitySample(new: [HKQuantitySample], deleted:[HKDeletedObject], dataType: dataType, unit: HKUnit){
        let sample = new.last!
        let timestamp = getTimestamp(sample: sample)
        
        print(timestamp)
        print("last sample = \(String(describing: new.last!.quantity))")
        
        if(firstUpload){
            StorageManager.sharedInstance.deleteAllData(entityName: "Data")
            for s in new {
                StorageManager.sharedInstance.addData(entityName: "Data", type: dataType.rawValue, timestamp: getTimestamp(sample: s), value: (((s.quantity.doubleValue(for: unit)))))
            }
            firstUpload = false
        }
        else{
            StorageManager.sharedInstance.addData(entityName: "Data", type: dataType.rawValue, timestamp: timestamp, value: (((new.last?.quantity.doubleValue(for: unit))!)))
        }
    }
    
    
    func initTimer(){
        DispatchQueue.global(qos: .background).async {
            while (true) {
                print("Timer fired!")
                
                print("Show all records:")
                let results = StorageManager.sharedInstance.getAllData(entityName: "Data")
                for data in results{
                    print(data.value(forKey: "type") as! String)
                    print(data.value(forKey: "timestamp") as! String)
                    print(data.value(forKey: "value") as! Double)
                }
                
                
                // Send all data
                
                /*
                 NetworkManager.sharedInstance.sendPostRequest(input: D4HDataUploadRequest(authToken:"6", types: [dataType.heartrate] ,values:[[Double(50)]], timestamps:[["timestamp"]]), endpoint: D4HEndpoint.login) { (response, error) in
                 if response != nil {
                 let myres = D4HLoginResponse(fromJson: response!)
                 print(myres.message)
                 }
                 else if let error = error {
                 print(error)
                 }
                 }*/
                
                StorageManager.sharedInstance.deleteAllData(entityName: "Data")
                
                sleep(5)
            }
        }
    }
}
