//
//  D4HObservation.swift
//  Data4Help
//
//  Created by Luca Molteni on 20/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class D4HObservation {
    
    // MARK: parameters
    
    let avg: Double
    let month: String
    let year: String
    
    // MARK: Initialisators
    
    init(avg: Double, month: String, year: String) {
        self.avg = avg
        self.month = month
        self.year = year
    }
    
    init(fromJson json: JSON) {
        self.avg = json["avg"].doubleValue
        self.month = json["month"].stringValue
        self.year = json["year"].stringValue
    }
}
