//
//  D4HLoginResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 27/11/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON

class D4HLoginResponse {
    
    // MARK: - Properties
    
    var message: String
    let authToken: String
    
    // MARK: - initialization
    
    init(message: String, authToken: String) {
        self.message = message
        self.authToken = authToken
    }
    
    init(fromJson json: JSON) {
        self.message = json["message"].stringValue
        self.authToken = json["authToken"].stringValue
    }
}
