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
    
    
    // Mark: Functions
    
    
    /*Gets all data of specified entity*/
    func getAllData(entityName:String) -> [NSManagedObject]{
        var array: [NSManagedObject] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if (result.count==0) {print("Empty Storage")} //debug
            for data in result as! [NSManagedObject] {
                array.append(data)
            }
            
        } catch {
            print("Failed fetching data")
        }
        return array
    }
   
    /*Stores data of indicated type with specified timestamp, type, value*/
    func addData(entityName: String, type: String, timestamp: String, value: Double){
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let newData = NSManagedObject(entity: entity!, insertInto: context)
        newData.setValue(type, forKey: "type")
        newData.setValue(timestamp, forKey: "timestamp")
        newData.setValue(value, forKey: "value")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func storeBiologicalSex(biologicalSex: String){
        let entity = NSEntityDescription.entity(forEntityName: "BiologicalSex", in: context)
        let newData = NSManagedObject(entity: entity!, insertInto: context)
        newData.setValue(biologicalSex, forKey: "biologicalSex")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func setAutomatedSOSValue(value: Bool){        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AutomatedSOS")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            (results[0] as! NSManagedObject).setValue(value, forKey: "enabled")
        } catch {
            print("Failed fetching data")
        }
        
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    func initAutomatedSOS(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AutomatedSOS")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if (result.count>0){
                return;
            }
        } catch {
            //No action
        }
        let entity = NSEntityDescription.entity(forEntityName: "AutomatedSOS", in: context)
        let newData = NSManagedObject(entity: entity!, insertInto: context)
        newData.setValue(false, forKey: "enabled")
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    func deleteAllData(entityName: String) {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
        } catch {
            print ("Could not delete all data")
        }
    }
    
}
