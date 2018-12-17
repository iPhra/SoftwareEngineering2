//
//  D4HSingleUserInfoResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 17/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HSingleUserInfoResponse: D4HResponse {
    
    // MARK: - Properties
    
    let email: String
    let fc: String
    let full_name: String
    let birthdate: String
    
    // MARK: - initialization
    
    init(email: String, fc: String, full_name: String, birthdate: String) {
        self.email = email
        self.fc = fc
        self.full_name = full_name
        self.birthdate = birthdate
    }
    
    init(fromJson json: JSON) {
        let infoJson = json["settings"]
        self.email = infoJson["email"].stringValue
        self.fc = infoJson["fc"].stringValue
        self.full_name = infoJson["full_name"].stringValue
        self.birthdate = infoJson["birthdate"].stringValue
    }
}
