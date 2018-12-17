//
//  D4HThirdPartyInfoResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 17/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HThirdPartyInfoResponse: D4HResponse {
    
    // MARK: - Properties
    
    let email: String
    let piva: String
    let company_name: String
    let company_description: String
    
    // MARK: - initialization
    
    init(email: String, piva: String, company_name: String, company_description: String) {
        self.email = email
        self.piva = piva
        self.company_name = company_name
        self.company_description = company_description
    }
    
    init(fromJson json: JSON) {
        let infoJson = json["settings"]
        self.email = infoJson["email"].stringValue
        self.piva = infoJson["piva"].stringValue
        self.company_name = infoJson["company_name"].stringValue
        self.company_description = infoJson["company_description"].stringValue
    }
}
