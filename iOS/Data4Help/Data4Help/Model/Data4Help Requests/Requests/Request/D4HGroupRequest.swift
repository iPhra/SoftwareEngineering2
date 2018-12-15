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
    
    let authToken: String
    let types: [dataType]
    let parameters: [dataType]
    let bounds: [String]
    let subscribing: Bool
    let duration: Int
    
    // MARK: Initialisation
    
    init(authToken: String, types: [dataType], parameters: [dataType], bounds: [String], subscribing: Bool, duration: Int) {
        self.authToken = authToken
        self.types = types
        self.parameters = parameters
        self.bounds = bounds
        self.subscribing = subscribing
        self.duration = duration
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "authToken": authToken,
            "types": types,
            "parameters": parameters,
            "bounds": bounds,
            "subscribing": subscribing,
            "duration": duration
        ]
        print(params)
        return params
    }
}
