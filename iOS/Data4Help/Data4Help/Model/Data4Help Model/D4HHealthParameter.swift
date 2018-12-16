//
//  D4HHealthParameter.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON

class D4HHealthParameter {
    
    // MARK: - Properties
    
    let datatype: dataType
    let upperbound: Int
    let lowerbound: Int
    
    // MARK: - initialization
    
    init( datatype: dataType, upperbound: Int, lowerbound: Int) {
        self.datatype = datatype
        self.upperbound = upperbound
        self.lowerbound = lowerbound
    }
    
    init(fromJson json: JSON) {
        let type = json["datatype"].stringValue
        self.datatype = dataType(rawValue: type)!
        self.upperbound = json["upperbound"].intValue
        self.lowerbound = json["lowerbound"].intValue
    }
    
}

