//
//  CacheManager.swift
//  Data4Help
//
//  Created by Virginia Negri on 04/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class CacheManager: NSObject {
    
    let healthDataCache = NSCache<NSString, AnyObject>()
    
    func storeData(timestamp: String, value:Int, completion: @escaping (_ image: Int?, _ error: Error? ) -> Void) {
        if let cachedData = healthDataCache.object(forKey: timestamp as NSString) {
            completion((cachedData as! Int), nil)
        }
        else {
            healthDataCache.setObject(value as AnyObject, forKey: timestamp as NSString)
        }
    }
    
    func getData(id: String) -> AnyObject {
        return healthDataCache.object(forKey: id as NSString)!
    }
}
