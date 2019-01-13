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
    
    let password: String
    let company_name: String
    let company_description: String
    
    // MARK: Initialisation
    
    init(password: String, company_name: String, company_description: String) {
        self.password = password
        self.company_name = company_name
        self.company_description = company_description
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        var params: Parameters = [:]
        if(!password.isEmpty) {
            params["password"] = password.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if(!company_name.isEmpty) {
            params["company_name"] = company_name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if(!company_description.isEmpty) {
            params["company_description"] = company_description.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        print(params)
        return params
    }
}

