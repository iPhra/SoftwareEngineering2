//
//  D4HBound.swift
//  Data4Help
//
//  Created by Luca Molteni on 20/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class D4HBound {
    
    // MARK: parameters
    
    let upperbound: Double?
    let lowerbound: Double?
    
    // MARK: Initialisators
    
    init(upperbound: Double, lowerbound: Double) {
        self.upperbound = upperbound
        self.lowerbound = lowerbound
    }
    
    // MARK: Networking
    
    func getParams() -> Parameters {
        var params: Parameters = [:]
        if upperbound != nil {
            params["upperBound"] = upperbound
        }
        if lowerbound != nil {
            params["lowerbound"] = lowerbound
        }
        print(params)
        return params
    }
}
