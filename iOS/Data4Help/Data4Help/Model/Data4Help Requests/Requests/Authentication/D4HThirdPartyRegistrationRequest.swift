//
//  D4HThirdPartyRegistrationRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 06/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HThirdPartyRegistrationRequest: D4HRequest {
    
    // MARK: - Properties

    let email: String
    let password: String
    let PIVA: String
    let companyName: String
    let companyDescription: String
    
    // MARK: Initialisation
    
    init(email: String, password: String, PIVA: String, companyName: String, companyDescription: String) {
        self.email = email
        self.password = password
        self.PIVA = PIVA
        self.companyName = companyName
        self.companyDescription = companyDescription
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "email": email,
            "password": password,
            "piva": PIVA,
            "company_name": companyName,
            "companyDescription": companyDescription,
            ]
        print(params)
        return params
    }
    
    
}
