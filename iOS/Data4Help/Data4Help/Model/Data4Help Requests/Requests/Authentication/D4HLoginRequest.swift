//
//  D4HLoginRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 27/11/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HLoginRequest: D4HRequest {
    
    // MARK: - Properties
    
    let email: String
    let password: String
    
    // MARK: Initialisation
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        print(params)
        return params
    }
}
