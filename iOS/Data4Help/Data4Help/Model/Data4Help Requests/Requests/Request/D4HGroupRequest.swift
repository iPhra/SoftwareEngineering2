//
//  D4HGroupRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 15/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HGroupRequest: D4HRequest {
    
    // MARK: - Properties
    
    let types: [String]
    let parameters: [String]
    let bounds: [D4HBound]
    let subscribing: Bool
    let duration: Int
    
    // MARK: Initialisation
    
    init(types: [String], parameters: [String], bounds: [D4HBound], subscribing: Bool, duration: Int) {
        self.types = types
        self.parameters = parameters
        self.bounds = bounds
        self.subscribing = subscribing
        self.duration = duration
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        var boundsParam: [Parameters] = []
        for bound in bounds {
            boundsParam.append(bound.getParams())
        }
        var params: Parameters = [
            "types": types,
            "parameters": parameters,
            "bounds": boundsParam,
            "subscribing": subscribing
        ]
        if subscribing {
            params["duration"] = duration
        }
        print(params)
        return params
    }
}
