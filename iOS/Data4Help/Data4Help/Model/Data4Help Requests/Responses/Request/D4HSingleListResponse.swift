//
//  D4HSingleListResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HSingleListResponse: D4HResponse {
    
    // MARK: - Properties
    
    var requests: [SUSingleRequest]
    
    // MARK: - initialization
    
    init(requests: [SUSingleRequest]) {
        self.requests = requests
    }
    
    init(fromJson json: JSON) {
        
        self.requests = []
        let requestsJson = json["requests"].arrayValue
        for requestJson in requestsJson {
            self.requests.append(SUSingleRequest(fromJson: requestJson))
        }
        
    }
}
