//
//  D4HSingleUserSettingsRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 14/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HSingleUserSettingsRequest: D4HRequest {
    
    // MARK: - Properties
    
    let password: String
    let fullname: String
    let birthdate: String
    
    // MARK: Initialisation
    
    init(password: String, fullname: String, birthdate: String) {
        self.password = password
        self.fullname = fullname
        self.birthdate = birthdate
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        var params: Parameters = [:]
        if(!password.isEmpty) {
            params["password"] = password
        }
        if(!fullname.isEmpty) {
            params["full_name"] = fullname
        }
        if(!birthdate.isEmpty) {
            params["birthdate"] = birthdate
        }
        print(params)
        return params
    }
}
