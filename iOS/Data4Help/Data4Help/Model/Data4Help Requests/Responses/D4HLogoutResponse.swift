//
//  D4HLogoutResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 14/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON

class D4HLogoutResponse: D4HResponse {
    
    // MARK: - Properties
    
    var message: String
    
    // MARK: - initialization
    
    init(message: String) {
        self.message = message
    }
    
    init(fromJson json: JSON) {
        self.message = json["message"].stringValue
    }
}
