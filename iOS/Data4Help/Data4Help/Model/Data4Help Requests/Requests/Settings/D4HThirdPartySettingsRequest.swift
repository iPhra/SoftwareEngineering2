//
//  D4HThirdPartySettingsRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 14/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HThirdPartySettingsRequest: D4HRequest {
    
    // MARK: - Properties
    
    let authToken: String
    let password: String
    let company_name: String
    let company_description: String
    
    // MARK: Initialisation
    
    init(authToken: String, password: String, company_name: String, company_description: String) {
        self.authToken = authToken
        self.password = password
        self.company_name = company_name
        self.company_description = company_description
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        var params: Parameters = [
            "authToken": authToken
        ]
        if(!password.isEmpty) {
            params["password"] = password
        }
        if(!company_name.isEmpty) {
            params["company_name"] = company_name
        }
        if(!company_description.isEmpty) {
            params["company_description"] = company_description
        }
        print(params)
        return params
    }
}

