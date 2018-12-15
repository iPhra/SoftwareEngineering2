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
    
    let authToken: String
    let email: String
    let fc: String
    let types: [dataType]
    let subscribing: Bool
    let duration: Int
    
    // MARK: Initialisation
    
    init(authToken: String, email: String, fc: String, types: [dataType], subscribing: Bool, duration: Int) {
        self.authToken = authToken
        self.email = email
        self.fc = fc
        self.types = types
        self.subscribing = subscribing
        self.duration = duration
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "authToken": authToken,
            "email": email,
            "fc": fc,
            "types": authToken,
            "subscribing": subscribing,
            "duration": duration
        ]
        print(params)
        return params
    }
}
