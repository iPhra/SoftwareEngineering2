//
//  D4HThirdPartyListResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HThirdPartyListResponse: D4HResponse {
    
    // MARK: - Properties
    
    var singleRequests: [TPSingleRequest]
    var groupRequests: [TPGroupRequest]
    
    // MARK: - initialization
    
    init(singleRequests: [TPSingleRequest], groupRequests: [TPGroupRequest]) {
        self.singleRequests = singleRequests
        self.groupRequests = groupRequests
    }
    
    init(fromJson json: JSON) {
        
        let requestsJson = json["requests"]
        self.singleRequests = []
        let singleRequestsJson = requestsJson["single"].arrayValue
        for singleRequestJson in singleRequestsJson {
            self.singleRequests.append(TPSingleRequest(fromJson: singleRequestJson))
        }
        self.groupRequests = []
        let groupRequestsJson = requestsJson["group"].arrayValue
        for groupRequestJson in groupRequestsJson {
            self.groupRequests.append(TPGroupRequest(fromJson: groupRequestJson))
        }
    }
        
}
