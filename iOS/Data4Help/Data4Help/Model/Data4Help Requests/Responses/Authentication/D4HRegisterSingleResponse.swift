//
//  D4HRegisterSingleResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 03/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HRegisterSingleResponse: D4HResponse {
    
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
