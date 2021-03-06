//
//  D4HSingleRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 15/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HSingleRequest: D4HRequest {
    
    // MARK: - Properties
    
    let email: String
    let fc: String
    let types: [String]
    let subscribing: Bool
    let duration: Int
    
    // MARK: Initialisation
    
    init(email: String, fc: String, types: [String], subscribing: Bool, duration: Int) {
        self.email = email
        self.fc = fc
        self.types = types
        self.subscribing = subscribing
        self.duration = duration
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        var params: Parameters = [

            "types": types,
            "subscribing": subscribing
        ]
        if subscribing {
            params["duration"] = duration
        }
        if !email.isEmpty {
            params["email"] = email
        }
        if !fc.isEmpty {
            params["fc"] = fc
        }
        print(params)
        return params
    }
}
