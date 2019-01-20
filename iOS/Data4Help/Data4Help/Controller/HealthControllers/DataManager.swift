//
//  AutomatedSOSManager.swift
//  Data4Help
//
//  Created by Virginia Negri on 27/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

/*
 * Handles health data access thorugh HKHealthStore object
 */
class DataManager {
    
    // MARK: Properties
    
    var startDate: Date = Calendar.current.date(
        byAdding: .weekOfYear,
        value: -1,
        to: Date())!
    let calendar = Calendar.current
    
    var myHealth: MyHealth?
    
    var firstUploads: [dataType : Bool] = [
        dataType.activeEnergyBurned : true,
        dataType.heartrate : true,
        dataType.sleepingHours : true,
        dataType.standingHours : true,
        dataType.steps : true,
        dataType.distanceWalkingRunning : true,
        dataType.height : true,
        dataType.weight : true,
        dataType.bloodPressure : true
    ]
    
    var dataTypesToRead: [String] = [ dataType.activeEnergyBurned.rawValue,
                                        dataType.diastolic_pressure.rawValue,
                                        dataType.systolic_pressure.rawValue,
                                        dataType.distanceWalkingRunning.rawValue,
                                        dataType.heartrate.rawValue,
                                        dataType.height.rawValue,
                                        dataType.sleepingHours.rawValue,
                                        dataType.standingHours.rawValue,
                                        dataType.steps.rawValue,
                                        dataType.weight.rawValue]
    
    var currentValues: [String: Double] = [
        dataType.activeEnergyBurned.rawValue : 0,
        dataType.diastolic_pressure.rawValue : 0,
        dataType.systolic_pressure.rawValue : 0,
        dataType.distanceWalkingRunning.rawValue : 0,
        dataType.heartrate.rawValue : 0,
        dataType.height.rawValue : 0,
        dataType.sleepingHours.rawValue : 0,
        dataType.standingHours.rawValue : 0,
        dataType.steps.rawValue : 0,
        dataType.weight.rawValue : 0,
        ]
        
    var AutomatedSOSON = StorageManager.sharedInstance.getAutomatedSOS()
    
    let healthStore:HKHealthStore = HKHealthStore()
    
    let automatedSOSManager: AutomatedSOSManager = AutomatedSOSManager()
    
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
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!
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
    
    func getCurrentValue(datatype: String) -> Double {
        return self.currentValues[datatype] ?? 0
    }
    
    // Mark: Automated SOS handlers
    
    public func toggleAutomatedSOS(){
        if(AutomatedSOSON){
            AutomatedSOSON = false;
        }
        else{
            AutomatedSOSON = true;
        }
        StorageManager.sharedInstance.setAutomatedSOSValue(value: AutomatedSOSON)
    }
    
    public func enableAutomatedSOS(){
        if(!AutomatedSOSON){
            AutomatedSOSON = true;
            StorageManager.sharedInstance.setAutomatedSOSValue(value: AutomatedSOSON)
            myHealth?.automatedSOSSwitch.setOn(true, animated: true)
        }
    }
    
    public func getStoredAutomatedSOSValue() -> Bool{
        return StorageManager.sharedInstance.getAutomatedSOS()
    }
    
    // Mark: Data import handlers
    
    public func sampleTypesToRead() -> [HKSampleType] {
        var sampleTypes = [HKSampleType]()
        sampleTypes.append(HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
        sampleTypes.append(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!)
        sampleTypes.append(HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!)
        sampleTypes.append(HKSampleType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure)!)
        
        return sampleTypes
    }
    
    public func getDataTypeFromSampleType(hkSampleType: HKSampleType)-> dataType {
        switch(hkSampleType){
        case(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)):
            return dataType.activeEnergyBurned
        case(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)):
            return dataType.heartrate
        case(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)):
            return dataType.steps
        case(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)):
            return dataType.distanceWalkingRunning
        case(HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)):
            return dataType.height
        case(HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)):
            return dataType.sleepingHours
        case(HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)):
            return dataType.standingHours
        case(HKSampleType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure)):
            return dataType.bloodPressure
        default:
            return dataType.heartrate
        }
    }
    
    // Mark: Background activities
    
    public func storeBiologicalSex(){
        let sex = self.getBiologicalSex()
        StorageManager.sharedInstance.storeBiologicalSex(biologicalSex: sex)
    }
    
    func getBiologicalSex() -> String {
        var sex: String = ""
        do{
            let biologicalSex = try self.healthStore.biologicalSex().biologicalSex.rawValue
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
            return sex
        }
        catch{
            print("Could not retrieve biological sex")
        }
        return sex
    }
    
    public func enableBackgroundData(input: HKSampleType, datatype: dataType){
        
        self.healthStore.enableBackgroundDelivery(for: input, frequency: .immediate) { (success, error) in
            if let unwrappedError = error {
                print("could not enable background delivery: \(unwrappedError)")
            }
            if success {
                print("background delivery enabled")
            }
        }
        //2.  open observer query
        let query = HKObserverQuery(sampleType: input, predicate: nil) { (query, completionHandler, error) in
            
            self.updateHealthData(sampleType: input, datatype: datatype) {
                completionHandler()
            }
            
        }
        healthStore.execute(query)
        
    }
    
     public func disableBackgroundDelivery(){
        self.healthStore.disableAllBackgroundDelivery { (success, error) in
            if let unwrappedError = error {
                print("could not disable background delivery: \(unwrappedError)")
            }
            if success {
                print("background delivery disabled")
            }
        }
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
            case(dataType.activeEnergyBurned.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!,dataType: datatype, unit: HKUnit.kilocalorie())
            case(dataType.steps.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!,dataType: datatype, unit: HKUnit.count())
            case(dataType.weight.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!, dataType: datatype,unit: HKUnit.pound())
            case(dataType.height.rawValue):
                self.handleQuantitySample(new: newSamples! as! [HKQuantitySample], deleted: deletedSamples!, dataType: datatype,unit: HKUnit.foot())
            case(dataType.bloodPressure.rawValue):
                self.handleBloodPressureSample(new: newSamples! as! [HKCorrelation], deleted: deletedSamples!)
            default:
                break
            }
            
            anchor = newAnchor
            
            completionHandler()
        }
        healthStore.execute(anchoredQuery)
    }
    
    func handleSleepingHours(new: [HKCategorySample], deleted:[HKDeletedObject]) {
        if(new.count==0){
            return
        }
    self.currentValues.updateValue((new.last!.endDate.timeIntervalSince(new.last!.startDate))/3600, forKey: dataType.sleepingHours.rawValue)
        
        if(firstUploads[dataType.sleepingHours]!){
            var dataValues: [Double] = []
            var timestamps: [String] = []
            for s in new {
                let sampleDate: Date = s.startDate
                let components = calendar.dateComponents([.day], from: startDate, to: sampleDate)
                if((components.day ?? 0) < 8 && (components.day ?? 0) > -1){
                    let sleptHours : Double = (s.endDate.timeIntervalSince(s.startDate))/3600
                    dataValues.append(sleptHours)
                    timestamps.append(getTimestamp(sample: s))
                }
            }
            NetworkManager.sharedInstance.sendPostRequest(input: D4HDataUploadRequest(types: [dataType.sleepingHours.rawValue], values: [dataValues], timestamps: [timestamps]), endpoint: D4HEndpoint.uploadData, headers: Properties.auth()) { (response, error) in
                if response != nil {
                    let myres = D4HDataUploadResponse(fromJson: response!)
                    print(myres.message)
                }
                else if let error = error {
                    print(error)
                }
            }
            firstUploads.updateValue(false, forKey: dataType.sleepingHours)
        }
        else{
            let sample = new.last!
            let sleepType = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
            let timestamp = getTimestamp(sample: sample)
            let sleptHours: Double = (sample.endDate.timeIntervalSince(sample.startDate))/3600
            print(sleptHours)
            
            print (timestamp) //print date-time
            print("hours \(sleepType) = \(sleptHours)")
            
            StorageManager.sharedInstance.addData(entityName: "Data", type: dataType.sleepingHours.rawValue, timestamp: timestamp, value: sleptHours)
        }
        
    }
    
    func handleStandingHours(new: [HKCategorySample], deleted:[HKDeletedObject]) {
        if(new.count==0){
            return
        }
    self.currentValues.updateValue((new.last!.endDate.timeIntervalSince(new.last!.startDate))/3600, forKey: dataType.standingHours.rawValue)
        
        if(firstUploads[dataType.sleepingHours]!){
            var dataValues: [Double] = []
            var timestamps: [String] = []
            for s in new {
                let sampleDate: Date = s.startDate
                let components = calendar.dateComponents([.day], from: startDate, to: sampleDate)
                if((components.day ?? 0) < 8 && (components.day ?? 0) > -1){
                    let standingHours: Double = (s.endDate.timeIntervalSince(s.startDate))/3600
                    dataValues.append(standingHours)
                    timestamps.append(getTimestamp(sample: s))
                }
            }
            NetworkManager.sharedInstance.sendPostRequest(input: D4HDataUploadRequest(types: [dataType.standingHours.rawValue], values: [dataValues], timestamps: [timestamps]), endpoint: D4HEndpoint.uploadData, headers: Properties.auth()) { (response, error) in
                if response != nil {
                    let myres = D4HDataUploadResponse(fromJson: response!)
                    print(myres.message)
                }
                else if let error = error {
                    print(error)
                }
            }
            firstUploads.updateValue(false, forKey: dataType.sleepingHours)
        }
        else{
            let sample = new.last!
            let timestamp = getTimestamp(sample: sample)
            let standingHours: Double = (sample.endDate.timeIntervalSince(sample.startDate))/3600
            print(standingHours)
            
            StorageManager.sharedInstance.addData(entityName: "Data", type: dataType.sleepingHours.rawValue, timestamp: timestamp, value: standingHours)
        }
    }
    
    func getTimestamp(sample: HKSample)-> String{
        let delimiter = "+" //remove time zone
        var token = sample.endDate.description.components(separatedBy: delimiter)
        var timestamp = token[0]
        _ = timestamp.popLast()
        return timestamp
    }
    
    
    func handleQuantitySample(new: [HKQuantitySample], deleted:[HKDeletedObject], dataType: dataType, unit: HKUnit){
        if(new.count==0){
            return
        }
        let sample = new.last!
        let timestamp = getTimestamp(sample: sample)
        
        print(timestamp)
        print("last sample = \(String(describing: sample.quantity))")
        
        self.currentValues.updateValue(new.last!.quantity.doubleValue(for: unit), forKey: dataType.rawValue)
        
        if(firstUploads[dataType]!){
            var dataValues: [Double] = []
            var timestamps: [String] = []
            for s in new {
                let sampleDate: Date = s.startDate
                let components = calendar.dateComponents([.day], from: startDate, to: sampleDate)
                if((components.day ?? 0) < 8 && (components.day ?? 0) > -1){
                    dataValues.append(s.quantity.doubleValue(for: unit))
                    timestamps.append(getTimestamp(sample: s))
                    
                }
                let diffMinutes = calendar.dateComponents([.minute], from: Date(), to: sampleDate).minute ?? 0
                
                if( dataType == .heartrate && diffMinutes < 1 && diffMinutes > -1 ){
                    self.automatedSOSManager.checkHeartRate(heartRate: (new.last?.quantity.doubleValue(for: unit))!, timestamp: timestamp)
                }
            }
            NetworkManager.sharedInstance.sendPostRequest(input: D4HDataUploadRequest(types: [dataType.rawValue], values: [dataValues], timestamps: [timestamps]), endpoint: D4HEndpoint.uploadData, headers: Properties.auth()) { (response, error) in
                if response != nil {
                    let myres = D4HDataUploadResponse(fromJson: response!)
                    print(myres.message)
                }
                else if let error = error {
                    print(error)
                }
            }
            firstUploads.updateValue(false, forKey: dataType)
        }
        else{
            let diffMinutes = calendar.dateComponents([.minute], from: Date(), to: ((new.last)?.startDate)!).minute!
            if(dataType == .heartrate && diffMinutes < 1 && diffMinutes > -1){
                self.automatedSOSManager.checkHeartRate(heartRate: (new.last?.quantity.doubleValue(for: unit))!, timestamp: timestamp)
            }
            
            StorageManager.sharedInstance.addData(entityName: "Data", type: dataType.rawValue, timestamp: timestamp, value: (((new.last?.quantity.doubleValue(for: unit))!)))
        }
    }
    
    func handleBloodPressureSample(new: [HKCorrelation], deleted: [HKDeletedObject]){
        if(new.count==0){
            return
        }
        var diastolic: HKQuantitySample?
        var systolic: HKQuantitySample?
        var dTimestamp: String?
        var sTimestamp: String?
        
        let correlation = new.last
        diastolic = correlation!.objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!).first as? HKQuantitySample
        systolic = correlation!.objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!).first as? HKQuantitySample
        self.currentValues.updateValue((systolic?.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))!, forKey: dataType.systolic_pressure.rawValue)
        self.currentValues.updateValue((diastolic?.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))!, forKey: dataType.diastolic_pressure.rawValue)

        
        if(firstUploads[dataType.bloodPressure]!){
            var diastolicValues: [Double] = []
            var systolicaValues: [Double] = []
            var diastolicTimestamps: [String] = []
            var systolicTimestamps: [String] = []
            for correlation in new{
                let sampleDate: Date = correlation.startDate
                let components = calendar.dateComponents([.day], from: startDate, to: sampleDate)
                if((components.day ?? 0) < 8 && (components.day ?? 0) > -1){
                    diastolic = correlation.objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!).first as? HKQuantitySample
                    dTimestamp = getTimestamp(sample: diastolic!)
                    systolic = correlation.objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!).first as? HKQuantitySample
                    sTimestamp = getTimestamp(sample: systolic!)
                
                    systolicaValues.append(systolic!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))
                    diastolicValues.append(diastolic!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))
                    diastolicTimestamps.append(dTimestamp!)
                    systolicTimestamps.append(sTimestamp!)
                    
                    print("systolic: \(systolic!.quantity)")
                    print("diastolic: \(diastolic!.quantity)")
                    
                    let diffMinutes = calendar.dateComponents([.minute], from: Date(), to: sampleDate).minute ?? 0
                    
                    if( diffMinutes < 1 && diffMinutes > -1 ){
                        self.automatedSOSManager.checkBloodPressure(systolic: systolic!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()), diastolyc: diastolic!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()), timestamp: sTimestamp!)
                    }
                }
            }
            
            NetworkManager.sharedInstance.sendPostRequest(input: D4HDataUploadRequest(types: [dataType.systolic_pressure.rawValue,dataType.diastolic_pressure.rawValue], values: [systolicaValues,diastolicValues], timestamps: [systolicTimestamps,diastolicTimestamps]), endpoint: D4HEndpoint.uploadData, headers: Properties.auth()) { (response, error) in
                if response != nil {
                    let myres = D4HDataUploadResponse(fromJson: response!)
                    print(myres.message)
                }
                else if let error = error {
                    print(error)
                }
            }
            
            firstUploads.updateValue(false, forKey: dataType.bloodPressure)
        }
        else{
            let correlation = new.last
            diastolic = correlation!.objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!).first as? HKQuantitySample
            dTimestamp = getTimestamp(sample: diastolic!)
            systolic = correlation!.objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!).first as? HKQuantitySample
            sTimestamp = getTimestamp(sample: systolic!)
            
            let diffMinutes = calendar.dateComponents([.minute], from: Date(), to: ((new.last)?.startDate)!).minute ?? 0
            
            if(diffMinutes < 1 && diffMinutes > -1) {
                self.automatedSOSManager.checkBloodPressure(systolic: systolic!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()), diastolyc: diastolic!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()), timestamp: sTimestamp!)
            }
        }
    }
    
    
    func initTimer(){
        DispatchQueue.global(qos: .background).async {
            while (Properties.authToken != "") {
                
                var dataTypes: [String] = []
                var dataValues: [[Double]] = []
                var dataTimestamps: [[String]] = []
                
                for dataType in self.dataTypesToRead{
                    let results = StorageManager.sharedInstance.getAllDataObjects(ofType: dataType)
                    var values: [Double] = []
                    var timestamps : [String] = []
                    if (results.count>0){
                        dataTypes.append(dataType)
                        for data in results{
                            values.append(data.value(forKey: "value") as! Double)
                            timestamps.append(data.value(forKey: "timestamp") as! String)
                        }
                        dataValues.append(values)
                        dataTimestamps.append(timestamps)
                    }
                }
                                
                // Send all data if present
                if(dataTypes.count>0){
                    NetworkManager.sharedInstance.sendPostRequest(input: D4HDataUploadRequest(types: dataTypes, values: dataValues, timestamps: dataTimestamps), endpoint: D4HEndpoint.uploadData, headers: Properties.auth()) { (response, error) in
                        if response != nil {
                            let myres = D4HDataUploadResponse(fromJson: response!)
                            print(myres.message)
                            StorageManager.sharedInstance.deleteAllData(entityName: "Data")
                        }
                        else if let error = error {
                            print(error)
                        }
                    }
                }
                
                // send new data each hour
                sleep(3600)
            }
        }
    }
}
