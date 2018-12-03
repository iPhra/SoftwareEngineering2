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

class D4HLoginRequest {
    
    // MARK: - Properties
    
    let email: String
    let password: String
    
    // MARK: Initialisation
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    // MARK: - Networking
    
    func getParams() -> Parameters {
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        print(params)
        return params
    }
}
