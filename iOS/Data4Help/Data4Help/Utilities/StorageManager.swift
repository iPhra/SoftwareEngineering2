//
//  CacheManager.swift
//  Data4Help
//
//  Created by Virginia Negri on 04/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import CoreData

class StorageManager: NSObject {
    
    // Mark: Singleton Instance
    
    class var sharedInstance: StorageManager {
        
        struct Singleton {
            static let instance = StorageManager()
        }
        
        return Singleton.instance
    }
    
    // Mark: Properites
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    override init() {
        privateContext.parent = context
    }
    
    // Mark: Functions
    
    
    /* Gets all data of specified entity */
    func getAllData(ofEntity: String) -> [NSManagedObject]{
        var array: [NSManagedObject] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ofEntity)
        request.returnsObjectsAsFaults = false
 
        do {
            //context.performAndWait {
                let result = try privateContext.fetch(request)
                if (result.count==0) {print("Empty Storage")} //debug
                for data in result as! [NSManagedObject] {
                    array.append(data)
                }
            //}
        }
        catch {
            print("Failed fetching data")
        }
        return array
    }
    
    /*Gets all "Data" entities of specified type*/
    func getAllData(ofType: String) -> [Double]{
        var result: [Double] = []
        let allData = self.getAllData(ofEntity: "Data")
        let filteredData = allData.filter { $0.value(forKeyPath: "type") as! String == ofType}
        if (filteredData.count==0) {print("Empty Storage")} //debug
        for data in filteredData {
                result.append(data.value(forKeyPath: "value") as! Double)
        }
        return result
    }
    
    /*Gets all "Data" entities of specified type*/
    func getAllDataObjects(ofType: String) -> [NSManagedObject]{
        let allData = self.getAllData(ofEntity: "Data")
        let filteredData = allData.filter { $0.value(forKeyPath: "type") as! String == ofType}
        if (filteredData.count==0) {print("Empty Storage")} //debug
        return filteredData
    }
    
    /*Gets last value of the specified data type*/
    func getLastDataValue(ofType: String) -> Double? {
        let results = self.getAllData(ofType: ofType)
        if(results.count==0){
            return nil
        }
        else{
            return results.last
        }
    }
   
    /*Stores data of indicated type with specified timestamp, type, value*/
    func addData(entityName: String, type: String, timestamp: String, value: Double){
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let newData = NSManagedObject(entity: entity!, insertInto: context)
        newData.setValue(type, forKey: "type")
        newData.setValue(timestamp, forKey: "timestamp")
        newData.setValue(value, forKey: "value")
        do {
            try privateContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func storeBiologicalSex(biologicalSex: String){
        let entity = NSEntityDescription.entity(forEntityName: "BiologicalSex", in: privateContext)
        let newData = NSManagedObject(entity: entity!, insertInto: privateContext)
        newData.setValue(biologicalSex, forKey: "biologicalSex")
        do {
            try privateContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func setAutomatedSOSValue(value: Bool){        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AutomatedSOS")
        request.returnsObjectsAsFaults = false
        do {
            let results = try privateContext.fetch(request)
            (results[0] as! NSManagedObject).setValue(value, forKey: "enabled")
        } catch {
            print("Failed fetching data")
        }
        
        do {
            try privateContext.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    func getAutomatedSOS() -> Bool{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AutomatedSOS")
        request.returnsObjectsAsFaults = false
        do {
            let result = try privateContext.fetch(request)
            if (result.count>0){
                let r = result[0] as! NSManagedObject
                return (r.value(forKey: "enabled")) as! Bool;
            }
        } catch {
        }
        return false
    }
    
    func initAutomatedSOS(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AutomatedSOS")
        request.returnsObjectsAsFaults = false
        do {
            let result = try privateContext.fetch(request)
            if (result.count>0){
                return;
            }
        } catch {
            //No action
        }
        let entity = NSEntityDescription.entity(forEntityName: "AutomatedSOS", in: privateContext)
        let newData = NSManagedObject(entity: entity!, insertInto: privateContext)
        newData.setValue(false, forKey: "enabled")
        do {
            try privateContext.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    func deleteAllData(entityName: String) {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try self.privateContext.execute(deleteRequest)
            try self.privateContext.save()
        } catch {
            print ("Could not delete all data")
        }
    }
    
}
